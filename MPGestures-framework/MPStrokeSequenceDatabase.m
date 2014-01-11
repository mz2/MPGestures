//
//  MPStrokeSequenceDatabase.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"

NSString * const MPStrokeSequenceDatabaseErrorDomain = @"MPStrokeSequenceDatabaseErrorDomain";

NSString * const MPStrokeSequenceDatabaseDidAddSequenceNotification
    = @"MPStrokeSequenceDatabaseDidAddSequenceNotification";
NSString * const MPStrokeSequenceDatabaseDidRemoveSequenceNotification
    = @"MPStrokeSequenceDatabaseDidRemoveSequenceNotification";


@interface MPStrokeSequenceDatabase ()
@property NSMutableDictionary *namedStrokeSequences;
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
    self = [super init];
    if (self)
    {
        
        _identifier = dictionary[@"identifier"];

        NSDictionary *strokeSequenceMap = dictionary[@"strokeSequenceMap"];
        
        _namedStrokeSequences
            = [NSMutableDictionary dictionaryWithCapacity:strokeSequenceMap.count];
        
        for (id k in strokeSequenceMap)
            _namedStrokeSequences[k] = [NSMutableSet setWithArray:[MPStrokeSequence strokeSequencesWithArrayOfDictionaries:strokeSequenceMap[k]]];
    }
    
    return self;
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

- (void)addStrokeSequence:(MPStrokeSequence *)sequence
{
    return [self addStrokeSequence:sequence notify:YES];
}

- (void)addStrokeSequence:(MPStrokeSequence *)sequence notify:(BOOL)notify
{
    assert(sequence.name);
    if (!_namedStrokeSequences[sequence.name])
        _namedStrokeSequences[sequence.name] = [NSMutableSet setWithCapacity:64];
    
    [_namedStrokeSequences[sequence.name] addObject:sequence];
    
    if (notify)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:MPStrokeSequenceDatabaseDidRemoveSequenceNotification
                          object:self userInfo:@{@"name":sequence.name}];
    }
}

- (void)addStrokeSequencesFromDatabase:(MPStrokeSequenceDatabase *)database
{
    assert(database);
    assert(database != self);
    
    for (MPStrokeSequence *seq in [database strokeSequenceSet])
        [self addStrokeSequence:seq notify:NO];
}

- (void)removeStrokeSequence:(MPStrokeSequence *)sequence
{
    assert(self[sequence.name]);
    [self[sequence.name] removeObject:sequence];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc postNotificationName:MPStrokeSequenceDatabaseDidRemoveSequenceNotification
                      object:self userInfo:@{@"name":sequence.name}];
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
