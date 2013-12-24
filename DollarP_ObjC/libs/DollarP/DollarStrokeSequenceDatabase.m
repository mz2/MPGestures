//
//  DollarStrokeSequenceDatabase.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "DollarStrokeSequenceDatabase.h"
#import "DollarStrokeSequence.h"


@interface DollarStrokeSequenceDatabase ()
@property NSMutableDictionary *namedStrokeSequences;
@end

@implementation DollarStrokeSequenceDatabase

- (instancetype)init
{
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _namedStrokeSequences = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
        
        for (id k in dictionary)
        {
            _namedStrokeSequences[k] = [DollarStrokeSequence strokeSequencesWithArrayOfDictionaries:dictionary[k]];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:_namedStrokeSequences.count];
    
    for (id k in _namedStrokeSequences)
    {
        dict[k] = [_namedStrokeSequences[k] valueForKey:@"dictionaryRepresentation"];
    }
    
    return dict;
}

- (void)addStrokeSequence:(DollarStrokeSequence *)sequence
{
    if (!_namedStrokeSequences[sequence.name])
        _namedStrokeSequences[sequence.name] = [NSMutableArray arrayWithCapacity:32];
    
    [_namedStrokeSequences[sequence.name] addObject:sequence];
}

@end
