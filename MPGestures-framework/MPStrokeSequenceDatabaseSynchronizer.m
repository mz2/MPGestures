//
//  MPStrokeSequenceDatabaseSynchronizer.m
//  MPGestures
//
//  Created by Matias Piipari on 06/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPStrokeSequenceDatabaseSynchronizer.h"
#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"

NSString * const MPStrokeSequenceDatabaseSynchronizerErrorDomain = @"MPStrokeSequenceDatabaseSynchronizerErrorDomain";
NSString * const MPStrokeSequenceDatabaseSynchronizerErrorNotification = @"MPStrokeSequenceDatabaseSynchronizerErrorNotification";
NSString * const MPStrokeSequenceDatabaseObjectSynchronizedNotification =
    @"MPStrokeSequenceDatabaseObjectSynchronizedNotification";

@interface MPStrokeSequenceDatabase ()
@property (readwrite, getter = isImmutable) BOOL immutable;
@end

@interface MPStrokeSequenceDatabaseSynchronizer ()
@property (readonly) NSMutableDictionary *databaseByIdentifier;
@property (readonly) dispatch_queue_t asyncRequestQueue;

/**
 *  Posts the add / removal requests synchronously. Synchronous mode not intended for production, only for testing.
 */
@property (readwrite) BOOL synchronousRequests;
@end

@implementation MPStrokeSequenceDatabaseSynchronizer

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"MPInitNotPermittedException"
                                   reason:nil userInfo:nil];
    return nil;
}

- (instancetype)initSynchronizer
{
    self = [super init];
    if (self)
    {
        _databaseByIdentifier = [NSMutableDictionary dictionary];
        [self updateContinuouslySynchronizedDatabases];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(didAddStrokeSequence:)
               name:MPStrokeSequenceDatabaseDidAddSequenceNotification
             object:nil];
    
    [nc addObserver:self selector:@selector(didRemoveStrokeSequence:)
               name:MPStrokeSequenceDatabaseDidRemoveSequenceNotification
             object:nil];
    return self;
}

+ (instancetype)sharedInstance
{
    static MPStrokeSequenceDatabaseSynchronizer *synchronizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        synchronizer = [[MPStrokeSequenceDatabaseSynchronizer alloc] initSynchronizer];
    });
    
    return synchronizer;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateContinuouslySynchronizedDatabases
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *keys = [[defs dictionaryRepresentation] allKeys];
    
    NSSet *keySet =
        [NSSet setWithArray:[keys filteredArrayUsingPredicate:
         [NSPredicate predicateWithBlock:
          ^BOOL(NSString *key, NSDictionary *bindings)
          {
              return [key hasPrefix:@"synchronizes-"] && [defs boolForKey:key];
          }]]];
    
    // remove the prefix from the filtered keys
    NSMutableSet *dbIDs = [NSMutableSet setWithCapacity:keySet.count];
    for (NSString *key in keySet)
        [dbIDs addObject:[key stringByReplacingOccurrencesOfString:@"synchronizes-" withString:@""]];
    
    _continuouslySynchronizedDatabaseIdentifiers = dbIDs;
    
    for (NSString *dbIdentifier in _continuouslySynchronizedDatabaseIdentifiers)
    {
        MPStrokeSequenceDatabase *db = _databaseByIdentifier[dbIdentifier];
        
        if (db)
            [self continuouslySynchronizeDatabase:db];
    }
}

- (NSString *)keyForDatabase:(MPStrokeSequenceDatabase *)database
{
    return [NSString stringWithFormat:@"synchronizes-%@", database.identifier];
}

- (void)continuouslySynchronizeDatabase:(MPStrokeSequenceDatabase *)database
{
    if (_databaseByIdentifier[database.identifier])
        assert(_databaseByIdentifier[database.identifier] == database);
    
    _databaseByIdentifier[database.identifier] = database;
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:@(YES) forKey:[self keyForDatabase:database]];
    [defs synchronize];
}

- (void)stopContinuouslySynchronizingDatabase:(MPStrokeSequenceDatabase *)database
{
    assert(_databaseByIdentifier[database.identifier] == database);
    [_databaseByIdentifier removeObjectForKey:database.identifier];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:[self keyForDatabase:database]];
    [defs synchronize];
}

- (BOOL)databaseIsContinuouslySynchronized:(MPStrokeSequenceDatabase *)database
{
    assert(database.identifier);
    
    return
        [[NSUserDefaults standardUserDefaults] boolForKey:[self keyForDatabase:database]];
}

#pragma mark - Notification observing

- (void)_addStrokeSequence:(MPStrokeSequence *)seq intoDatabase:(MPStrokeSequenceDatabase *)db
{
    NSError *err = nil;
    if (![self addStrokeSequence:seq intoDatabase:db error:&err])
    {
        assert(err);
        [[NSNotificationCenter defaultCenter] postNotificationName:MPStrokeSequenceDatabaseSynchronizerErrorNotification
                                                            object:err];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPStrokeSequenceDatabaseObjectSynchronizedNotification object:seq userInfo:@{@"database":db, @"operationType":@(MPSynchronizerOperationTypeAdd)}];
    }
}

- (void)_removeStrokeSequence:(MPStrokeSequence *)seq fromDatabase:(MPStrokeSequenceDatabase *)db
{
    NSError *err = nil;
    if (![self removeStrokeSequence:seq fromDatabase:db error:&err])
    {
        assert(err);
        [[NSNotificationCenter defaultCenter] postNotificationName:MPStrokeSequenceDatabaseSynchronizerErrorNotification
                                                            object:err];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPStrokeSequenceDatabaseObjectSynchronizedNotification object:seq userInfo:@{@"database":db,@"operationType":@(MPSynchronizerOperationTypeRemove)}];
    }
}

- (void)didAddStrokeSequence:(NSNotification *)notification
{
    MPStrokeSequenceDatabase *db = notification.object;
    assert([db isKindOfClass:[MPStrokeSequenceDatabase class]]);
    assert(db.identifier);
    
    MPStrokeSequence *seq = notification.userInfo[@"strokeSequence"];
    assert([seq isKindOfClass:[MPStrokeSequence class]]);
    assert(seq.signature);
    
    if (![_continuouslySynchronizedDatabaseIdentifiers containsObject:db.identifier])
        return;
    
    if (_synchronousRequests)
    {
        [self _addStrokeSequence:seq intoDatabase:db];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _addStrokeSequence:seq intoDatabase:db];
        });
    }
}

- (void)didRemoveStrokeSequence:(NSNotification *)notification
{
    MPStrokeSequenceDatabase *db = notification.object;
    assert([db isKindOfClass:[MPStrokeSequenceDatabase class]]);
    assert(db.identifier);
    
    MPStrokeSequence *seq = notification.userInfo[@"strokeSequence"];
    
    if (![_continuouslySynchronizedDatabaseIdentifiers containsObject:db.identifier])
        return;
    
    if (_synchronousRequests)
    {
        [self _removeStrokeSequence:seq fromDatabase:db];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _removeStrokeSequence:seq fromDatabase:db];
        });
    }
}

#pragma mark - Network IO

#pragma mark - URL generation

- (NSString *)baseURI
{
    return @"http://localhost:3000/gestures";
}

- (NSURL *)URLForDatabaseIdentifiers
{
    return [NSURL URLWithString:[[self baseURI] stringByAppendingPathComponent:@"index"]];
}

- (NSURL *)URLForDatabaseWithIdentifier:(NSString *)databaseID
{
    return [NSURL URLWithString:[[self baseURI] stringByAppendingPathComponent:databaseID]];
}

- (NSURL *)URLForDatabase:(MPStrokeSequenceDatabase *)database
{
    return [[NSURL URLWithString:self.baseURI] URLByAppendingPathComponent:database.identifier];
}

- (NSURL *)URLForAllGesturesDatabase
{
    return [NSURL URLWithString:[[self baseURI] stringByAppendingPathComponent:@"db/all"]];
}

- (NSURL *)URLForStrokeSequence:(MPStrokeSequence *)strokeSequence
                     inDatabase:(MPStrokeSequenceDatabase *)db
{
    assert(db);
    assert(db.identifier);
    assert(strokeSequence);
    assert(strokeSequence.name);
    
    return [[self URLForDatabase:db] URLByAppendingPathComponent:strokeSequence.name];
}

- (NSURL *)URLForStrokeSequenceSignature:(NSString *)signature
                inDatabaseWithIdentifier:(NSString *)identifier
{
    assert(signature);
    assert(identifier);
    
    return [[[self URLForDatabaseWithIdentifier:identifier]
                URLByAppendingPathComponent:@"signature"]
                    URLByAppendingPathComponent:signature];
}

#pragma mark - Request handling

- (NSString *)HTTPVerbForOperationType:(MPSynchronizerOperationType)operationType
{
    NSString *verb = nil;
    switch (operationType) {
        case MPSynchronizerOperationTypeList:
            verb = @"GET";
            break;
        case MPSynchronizerOperationTypeAdd:
            verb = @"POST";
            break;
        case MPSynchronizerOperationTypeRemove:
            verb = @"DELETE";
            break;
            
        default:
            @throw [NSException exceptionWithName:@"MPInvalidArgumentException"
                                           reason:[NSString stringWithFormat:@"Invalid operation type: %lu", operationType]
                                         userInfo:@{}];
            break;
    }
    
    return verb;
}

- (NSData *)requestBodyForAddingStrokeSequence:(MPStrokeSequence *)strokeSequence
                                  intoDatabase:(MPStrokeSequenceDatabase *)database
                                         error:(NSError **)err
{
    assert(strokeSequence);
    assert(strokeSequence.name);
    assert(database);
    assert(database.identifier);
    
    NSDictionary *dict = strokeSequence.dictionaryRepresentation;
    assert(dict);
    
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted
                                             error:err];
}

- (NSData *)requestBodyForRemovingStrokeSequence:(MPStrokeSequence *)strokeSequence
                                    fromDatabase:(MPStrokeSequenceDatabase *)database
                                           error:(NSError **)err
{
    assert(strokeSequence);
    assert(strokeSequence.name);
    assert(database);
    assert(database.identifier);

    NSDictionary *dict = @{@"name":strokeSequence.name, @"signature":strokeSequence.signature};
    
    return [NSJSONSerialization dataWithJSONObject:dict
                                    options:NSJSONWritingPrettyPrinted error:err];
}

- (NSData *)HTTPBodyForStrokeSequence:(MPStrokeSequence *)strokeSequence
                             database:(MPStrokeSequenceDatabase *)database
                            operation:(MPSynchronizerOperationType)operationType
                                error:(NSError **)err
{
    switch (operationType) {
        case MPSynchronizerOperationTypeList:
            return [NSData data];
            break;
        case MPSynchronizerOperationTypeAdd:
            return [self requestBodyForAddingStrokeSequence:strokeSequence
                                               intoDatabase:database error:err];
        case MPSynchronizerOperationTypeRemove:
            return [self requestBodyForRemovingStrokeSequence:strokeSequence
                                                 fromDatabase:database error:err];
        default:
            assert(false);
            break;
    }
}

- (id)requestWithStrokeSequence:(MPStrokeSequence *)strokeSequence
                     inDatabase:(MPStrokeSequenceDatabase *)db
                      operation:(MPSynchronizerOperationType)operationType
                          error:(NSError **)err
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[self URLForStrokeSequence:strokeSequence inDatabase:db]
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:-1];
    [req setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [req setHTTPMethod:[self HTTPVerbForOperationType:operationType]];
    
    NSData *body = [self HTTPBodyForStrokeSequence:strokeSequence database:db operation:operationType error:err];
    
    if (!body)
        return nil;

    [req setHTTPBody:body];
    
    // run the request
    NSHTTPURLResponse *resp = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:err];
    
    if (!data)
        return nil;
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:err];
    
    if (!responseDict)
    {
        if (err)
        {
            *err = [NSError errorWithDomain:MPStrokeSequenceDatabaseSynchronizerErrorDomain
                                       code:MPStrokeSequenceDatabaseSynchronizerErrorCodeInvalidResponse
                                   userInfo:@{NSLocalizedDescriptionKey :
                                                  [NSString stringWithFormat:@"Response was empty, with status code: %lu", resp.statusCode]}];
        }
    }
    
    if (responseDict[@"error"])
    {
        if (err)
            *err = [NSError errorWithDomain:MPStrokeSequenceDatabaseSynchronizerErrorDomain
                                       code:MPStrokeSequenceDatabaseSynchronizerErrorCodeServerReturnedError
                                   userInfo:@{NSLocalizedDescriptionKey :
                                                  [NSString stringWithFormat:@"%@", responseDict[@"error"]]}];
    }
    
    if (resp.statusCode == 200)
        return responseDict;
    
    return nil;
}

- (MPStrokeSequenceDatabase *)databaseWithIdentifier:(NSString *)identifier
                                               error:(NSError **)err
{
    return [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:[self URLForDatabaseWithIdentifier:identifier] error:err];
}

- (MPStrokeSequenceDatabase *)allGesturesDatabaseWithError:(NSError *__autoreleasing *)err
{
    MPStrokeSequenceDatabase *db =
        [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:[self URLForAllGesturesDatabase] error:err];
    db.immutable = YES;
    
    return db;
}

- (NSArray *)databaseIdentifiersWithError:(NSError **)err
{
    NSData *respData = [NSData dataWithContentsOfURL:[self URLForDatabaseIdentifiers] options:0 error:err];
    if (!respData)
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:respData options:0 error:err];
}

- (BOOL)addStrokeSequence:(MPStrokeSequence *)strokeSequence
             intoDatabase:(MPStrokeSequenceDatabase *)db
                    error:(NSError **)err
{
    return [self requestWithStrokeSequence:strokeSequence
                                inDatabase:db
                                 operation:MPSynchronizerOperationTypeAdd error:err] != nil;
}

- (NSArray *)strokeSequencesWithSignature:(NSString *)signature
                 inDatabaseWithIdentifier:(NSString *)identifier
                                    error:(NSError **)err
{
    NSData *strokeSequenceData = [NSData dataWithContentsOfURL:[self URLForStrokeSequenceSignature:signature inDatabaseWithIdentifier:identifier] options:0 error:err];
    
    if (!strokeSequenceData)
        return nil;
    
    NSArray *dicts = [NSJSONSerialization JSONObjectWithData:strokeSequenceData options:0 error:err];
    if (!dicts)
        return nil;
    
    return [MPStrokeSequence strokeSequencesWithArrayOfDictionaries:dicts];
}

- (BOOL)removeStrokeSequence:(MPStrokeSequence *)strokeSequence
                fromDatabase:(MPStrokeSequenceDatabase *)db
                       error:(NSError **)err
{
    return [self requestWithStrokeSequence:strokeSequence
                                inDatabase:db
                                 operation:MPSynchronizerOperationTypeRemove error:err] != nil;
}

@end