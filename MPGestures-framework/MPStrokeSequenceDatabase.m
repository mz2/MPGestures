//
//  MPStrokeSequenceDatabase.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"

#import <MPRandomForest/MPTrainingInstructions.h>
#import <MPRandomForest/MPDataTable.h>

NSString * const MPColumnNameStrokeSequenceObject = @"strokeSequence";
NSString * const MPColumnNameStrokeSequenceLabel = @"strokeSequenceLabel";
NSString * const MPCategoryNameStrokeSequenceLabel = @"strokeSequenceLabel";

NSString * const MPStrokeSequenceDatabaseErrorDomain = @"MPStrokeSequenceDatabaseErrorDomain";

NSString * const MPStrokeSequenceDatabaseDidAddSequenceNotification
    = @"MPStrokeSequenceDatabaseDidAddSequenceNotification";
NSString * const MPStrokeSequenceDatabaseDidRemoveSequenceNotification
    = @"MPStrokeSequenceDatabaseDidRemoveSequenceNotification";
NSString * const MPStrokeSequenceDatabaseChangedExternallyNotification
    = @"MPStrokeSequenceDatabaseChangedExternallyNotification";

@interface MPStrokeSequenceDatabase ()
@property NSMutableDictionary *namedStrokeSequences;
@property (readwrite, getter = isImmutable) BOOL immutable;
@end

@implementation MPStrokeSequenceDatabase

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"MPInvalidInitException" reason:nil userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    return [self initWithDictionary:@{@"identifier":identifier,
                                      @"strokeSequenceMap":@{}}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithIdentifier:dictionary[@"identifier"]
                  strokeSequenceMap:dictionary[@"strokeSequenceMap"]];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                    strokeSequence:(MPStrokeSequence *)strokeSequence
{
    return [self initWithIdentifier:identifier
                  strokeSequenceMap:@{strokeSequence.name : @[strokeSequence]}];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                 strokeSequenceMap:(NSDictionary *)strokeSequenceMap
{
    self = [super init];
    if (self) {
        _identifier = identifier;

        _namedStrokeSequences
            = [NSMutableDictionary dictionaryWithCapacity:strokeSequenceMap.count];
        
        
        for (id k in strokeSequenceMap) {
            NSArray *seqs = strokeSequenceMap[k];
            
            // FIXME: currently if first object is a stroke sequence, rest assumed so too.
            if (seqs.count > 0 && [seqs[0] isKindOfClass:[MPStrokeSequence class]]) {
                _namedStrokeSequences[k]
                    = [NSMutableSet setWithArray:seqs];
            }
            else {
                _namedStrokeSequences[k]
                    = [NSMutableSet setWithArray:[MPStrokeSequence strokeSequencesWithArrayOfDictionaries:seqs]];
            }
        }

    }
    return self;
}

- (instancetype)initWithStrokeSequenceDatabase:(MPStrokeSequenceDatabase *)seqDatabase
            maxStrokeSequencesWithMatchingName:(NSUInteger)maxCount
{
    if (maxCount <= 0)
        // TODO: don't serialize & deserialise for performance reasons.
        return [self initWithDictionary:seqDatabase.dictionaryRepresentation];
    
    NSArray *strokeSequences = [[seqDatabase.strokeSequenceSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSArray *names = [[seqDatabase.strokeSequenceNameSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableDictionary *nameIndices = [NSMutableDictionary dictionaryWithCapacity:names.count];
    
    for (NSUInteger i = 0; i < names.count; i++)
        nameIndices[names[i]] = @(i);
    
    NSMutableDictionary *outputStrokeSequenceMap = [NSMutableDictionary dictionaryWithCapacity:names.count * maxCount];
    
    NSUInteger *counts = malloc(names.count * sizeof(NSUInteger));
    for (MPStrokeSequence *seq in strokeSequences)
    {
        NSUInteger i = [nameIndices[seq.name] unsignedIntegerValue];
        
        if (counts[i] >= maxCount)
            continue;
            
        counts[i] += 1;
        
        if (!outputStrokeSequenceMap[seq.name])
            outputStrokeSequenceMap[seq.name] = [NSMutableArray arrayWithCapacity:maxCount];
        
        [outputStrokeSequenceMap[seq.name] addObject:seq];
    }
    free(counts);
    
    return [self initWithIdentifier:seqDatabase.identifier strokeSequenceMap:[outputStrokeSequenceMap copy]];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)err
{
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:err];
    if (!data)
        return nil;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:err];
    if (!dict)
        return nil;
    
    self = [self initWithDictionary:dict];
    return self;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err
{
    NSDictionary *dict = [self dictionaryRepresentation];
    assert(dict);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:err];
    if (!data) return NO;
    
    return [data writeToURL:url atomically:YES];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:_namedStrokeSequences.count];
    
    for (id k in _namedStrokeSequences)
    {
        dict[k] = [[_namedStrokeSequences[k] allObjects] valueForKey:@"dictionaryRepresentation"];
    }
    
    return @{@"identifier": self.identifier, @"strokeSequenceMap":dict};
}

- (id<MPTrainableDataSet>)dataSetRepresentation {
    MPDataTable *tbl =
    [[MPDataTable alloc] initWithColumnTypes:@[@(MPColumnTypeCustomObject), @(MPColumnTypeCategorical)]
                                 columnNames:
  @[MPColumnNameStrokeSequenceObject, MPColumnNameStrokeSequenceLabel]
                            labelColumnIndex:1
                               datumCapacity:self.strokeSequenceSet.count];
    [tbl addCategoryWithName:MPCategoryNameStrokeSequenceLabel
                      values:[[self.strokeSequenceNameSet allObjects] sortedArrayUsingSelector:@selector(compare:)]];
    [tbl assignCategoryWithName:MPCategoryNameStrokeSequenceLabel toColumnWithIndex:1];
    
    for (MPStrokeSequence *seq in [self.strokeSequenceSet.allObjects sortedArrayUsingSelector:@selector(compare:)]) {
        assert([tbl indexForCategoryValue:seq.name
                      forCategoryWithName:MPCategoryNameStrokeSequenceLabel] != NSNotFound);
        id<MPDatum> datum
            = [[MPDataTableRow alloc] initWithValues:@[seq, seq.name]
                                         columnTypes:tbl.columnTypes];
        [tbl appendDatum:datum];
    }
    
    return tbl;
}


- (void)addStrokeSequence:(MPStrokeSequence *)sequence
{
    return [self addStrokeSequence:sequence notify:YES];
}

- (void)addStrokeSequence:(MPStrokeSequence *)sequence notify:(BOOL)notify
{
    if (_immutable)
        @throw [NSException exceptionWithName:@"MPImmutableDatabaseException"
                                       reason:@"Attempting to manipulate an immutable database"
                                     userInfo:nil];
    
    assert(sequence.name);
    if (!_namedStrokeSequences[sequence.name])
        _namedStrokeSequences[sequence.name] = [NSMutableSet setWithCapacity:64];
    
    [_namedStrokeSequences[sequence.name] addObject:sequence];
    
    if (notify)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:MPStrokeSequenceDatabaseDidAddSequenceNotification
                          object:self userInfo:@{@"name":sequence.name, @"strokeSequence":sequence}];
    }
}

- (void)addStrokeSequencesFromDatabase:(MPStrokeSequenceDatabase *)database
{
    if (_immutable)
        @throw [NSException exceptionWithName:@"MPImmutableDatabaseException"
                                       reason:@"Attempting to manipulate an immutable database"
                                     userInfo:nil];
    assert(database);
    assert(database != self);
    
    for (MPStrokeSequence *seq in [database strokeSequenceSet])
        [self addStrokeSequence:seq notify:NO];
}

- (void)removeStrokeSequence:(MPStrokeSequence *)sequence
{
    if (_immutable)
        @throw [NSException exceptionWithName:@"MPImmutableDatabaseException"
                                       reason:@"Attempting to manipulate an immutable database"
                                     userInfo:nil];
    
    assert(self[sequence.name]);
    [self[sequence.name] removeObject:sequence];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc postNotificationName:MPStrokeSequenceDatabaseDidRemoveSequenceNotification
                      object:self userInfo:@{@"name":sequence.name, @"strokeSequence":sequence}];
}

- (BOOL)isEqual:(MPStrokeSequenceDatabase *)object
{
    if (!object)
    {
        return NO;
    }
    
    if (![object isKindOfClass:[MPStrokeSequenceDatabase class]])
    {
        return NO;
    }
    
    if (![self.identifier isEqualToString:object.identifier])
    {
        return NO;
    }
    
    return [self.namedStrokeSequences isEqualToDictionary:object.namedStrokeSequences];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    self.namedStrokeSequences[key] = obj;
}

- (id)objectForKeyedSubscript:(id)key
{
    return self.namedStrokeSequences[key];
}

- (NSSet *)strokeSequenceNameSet
{
    return [NSSet setWithArray:[self.namedStrokeSequences allKeys]];
}

- (NSArray *)sortedStrokeSequenceNames
{
    return [[self.strokeSequenceNameSet allObjects]
            sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSSet *)strokeSequenceSet
{
    return [NSSet setWithArray:
            [self.namedStrokeSequences.allValues valueForKeyPath:@"@unionOfSets.self"]];
}

@end
