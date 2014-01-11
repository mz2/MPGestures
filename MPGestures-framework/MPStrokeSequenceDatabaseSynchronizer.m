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

typedef NS_ENUM(NSInteger, MPRESTFulOperationType)
{
    MPRESTFulOperationTypeList = 0,
    MPRESTFulOperationTypeAdd = 1,
    MPRESTFulOperationTypeRemove = 2
};

@interface MPStrokeSequenceDatabaseSynchronizer ()
@property (readonly) NSMutableDictionary *databaseByIdentifier;
@end

@implementation MPStrokeSequenceDatabaseSynchronizer

- (instancetype)init
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateContinuouslySynchronizedDatabases
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *keys = [[defs dictionaryRepresentation] allKeys];
    
    _continuouslySynchronizedDatabaseIdentifiers =
        [NSSet setWithArray:[keys filteredArrayUsingPredicate:
         [NSPredicate predicateWithBlock:
          ^BOOL(NSString *key, NSDictionary *bindings)
          {
              return [key hasPrefix:@"synchronizes-"] && [defs boolForKey:key];
          }]]];
}

- (NSString *)keyForDatabase:(MPStrokeSequenceDatabase *)database
{
    return [NSString stringWithFormat:@"synchronizes-%@", database.identifier];
}

- (void)continuouslySynchronizeDatabase:(MPStrokeSequenceDatabase *)database
{
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

- (void)didAddStrokeSequence:(NSNotification *)notification
{
    MPStrokeSequenceDatabase *db = notification.object;
    assert([db isKindOfClass:[MPStrokeSequenceDatabase class]]);
    assert(db.identifier);
    
    if (![_continuouslySynchronizedDatabaseIdentifiers containsObject:db.identifier])
        return;
    
}

- (void)didRemoveStrokeSequence:(NSNotification *)notification
{
    MPStrokeSequenceDatabase *db = notification.object;
    assert([db isKindOfClass:[MPStrokeSequenceDatabase class]]);
    assert(db.identifier);
    
    if (![_continuouslySynchronizedDatabaseIdentifiers containsObject:db.identifier])
        return;

}

#pragma mark - Network IO

- (NSString *)baseURI
{
    return @"http://localhost:3000";
}

- (NSURL *)baseURL
{
    return [NSURL URLWithString:self.baseURI];
}

- (NSURL *)URLForStrokeSequence:(MPStrokeSequence *)strokeSequence
                     inDatabase:(MPStrokeSequenceDatabase *)db
{
    assert(db);
    assert(db.identifier);
    assert(strokeSequence);
    assert(strokeSequence.name);
    
    return [[[self baseURL] URLByAppendingPathComponent:db.identifier] URLByAppendingPathComponent:strokeSequence.name];
}

- (NSURL *)URLForDatabaseWithIdentifier:(NSString *)identifier
{
    assert(identifier);
    
    return [[self baseURL] URLByAppendingPathComponent:identifier];
}

- (NSString *)HTTPVerbForOperationType:(MPRESTFulOperationType)operationType
{
    NSString *verb = nil;
    switch (operationType) {
        case MPRESTFulOperationTypeList:
            verb = @"GET";
            break;
        case MPRESTFulOperationTypeAdd:
            verb = @"POST";
            break;
            
        case MPRESTFulOperationTypeRemove:
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

- (id)requestWithStrokeSequence:(MPStrokeSequence *)strokeSequence
                     inDatabase:(MPStrokeSequenceDatabase *)db
                      operation:(MPRESTFulOperationType)operationType
                          error:(NSError **)err
{
    NSMutableURLRequest *req = [NSURLRequest requestWithURL:[self URLForStrokeSequence:strokeSequence inDatabase:db]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:-1];
    [req setHTTPMethod:[self HTTPVerbForOperationType:operationType]];
    
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

- (MPStrokeSequenceDatabase *)databaseWithIdentifier:(NSString *)identifier error:(NSError **)err
{
    return [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:[self URLForDatabaseWithIdentifier:identifier] error:err];
}

- (BOOL)addStrokeSequence:(MPStrokeSequence *)strokeSequence intoDatabase:(MPStrokeSequenceDatabase *)db
                    error:(NSError *__autoreleasing *)err
{
    return [self requestWithStrokeSequence:strokeSequence inDatabase:db operation:MPRESTFulOperationTypeAdd error:err] != nil;
}

- (BOOL)removeStrokeSequence:(MPStrokeSequence *)strokeSequence fromDatabase:(MPStrokeSequenceDatabase *)db
                       error:(NSError **)err
{
    return [self requestWithStrokeSequence:strokeSequence inDatabase:db operation:MPRESTFulOperationTypeRemove error:err] != nil;
}

@end