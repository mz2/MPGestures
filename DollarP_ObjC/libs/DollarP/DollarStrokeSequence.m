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
    @throw [NSException exceptionWithName:@"MPInvalidInitException" reason:nil userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name strokes:(NSArray *)strokes
{
    self = [super init];
    if (self)
    {
        
        _name = name;
        _strokes = [strokes mutableCopy];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _name = dictionary[@"name"];
        _strokes = [[DollarStroke strokesWithArrayOfDictionaries:dictionary[@"strokes"]]
                    mutableCopy];
    }
    
    return self;
}

- (instancetype)initWithStrokeSequence:(DollarStrokeSequence *)sequence
{
    // FIXME: don't serialise & deserialise to make a deep copy of the strokes.
    return [self initWithName:sequence.name
                      strokes:[DollarStroke strokesWithArrayOfDictionaries:[sequence.strokes valueForKey:@"dictionaryRepresentation"]]];
}

- (BOOL)containsStroke:(DollarStroke *)stroke
{
    return [_strokes containsObject:stroke];
}

- (void)addStroke:(DollarStroke *)stroke
{
    [_strokes addObject:stroke];
}

- (NSArray *)strokesArray
{
    return [_strokes copy];
}

- (NSUInteger)strokeCount
{
    return _strokes.count;
}

- (DollarStroke *)lastStroke
{
    return [_strokes lastObject];
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

- (BOOL)isEqual:(DollarStrokeSequence *)object
{
    if (!object)
        return NO;
    
    if (![object isKindOfClass:[DollarStrokeSequence class]])
        return NO;
    
    if (![self.name isEqualToString:object.name])
        return NO;
    
    return [self.strokes isEqual:object.strokes];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<DollarStrokeSequence: name:%@ (%lu strokes) >",
            self.name,
            (unsigned long)self.strokeCount];
}

@end
