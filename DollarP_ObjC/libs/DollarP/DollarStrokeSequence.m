//
//  DollarStrokeSequence.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "DollarStrokeSequence.h"
#import "DollarStroke.h"

@interface DollarStrokeSequence ()
@property (readonly) NSMutableArray *strokes;
@end

@implementation DollarStrokeSequence

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _strokes = [NSMutableArray arrayWithCapacity:5];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _name = dictionary[@"name"];
        _strokes = [[DollarStroke strokesWithArrayOfDictionaries:dictionary[@"strokes"]] mutableCopy];
    }
    
    return self;
}

- (void)addStroke:(DollarStroke *)stroke
{
    [_strokes addObject:stroke];
}

- (NSArray *)strokesArray
{
    return [_strokes copy];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"name" : _name,
             @"strokes" : [_strokes valueForKey:@"dictionaryRepresentation"]};
}

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries
{
    NSMutableArray *strokeSequences = [NSMutableArray arrayWithCapacity:arrayOfDictionaries.count];
    for (NSDictionary *dict in arrayOfDictionaries)
        [strokeSequences addObject:[[DollarStrokeSequence alloc] initWithDictionary:dict]];
    
    return strokeSequences;
}

@end
