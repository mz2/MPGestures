//
//  DollarStrokeSequence.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPStrokeSequence.h"
#import "MPStroke.h"
#import "MPPointCloud.h"
#import "MPPoint.h"

@interface MPStrokeSequence ()
@property (readonly) NSMutableArray *strokes;
@end

@implementation MPStrokeSequence

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
        _strokes = [[MPStroke strokesWithArrayOfDictionaries:dictionary[@"strokes"]]
                    mutableCopy];
    }
    
    return self;
}

- (instancetype)initWithStrokeSequence:(MPStrokeSequence *)sequence
{
    // FIXME: don't serialise & deserialise to make a deep copy of the strokes.
    return [self initWithName:sequence.name
                      strokes:[MPStroke strokesWithArrayOfDictionaries:[sequence.strokes valueForKey:@"dictionaryRepresentation"]]];
}

- (BOOL)containsStroke:(MPStroke *)stroke
{
    return [_strokes containsObject:stroke];
}

- (void)addStroke:(MPStroke *)stroke
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

- (MPStroke *)lastStroke
{
    return [_strokes lastObject];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"name" : _name,
             @"strokes" : [_strokes valueForKey:@"dictionaryRepresentation"]};
}

- (MPPointCloud *)pointCloudRepresentationWithResampleCount:(NSUInteger)resampledPointCount
{
    NSArray *points = [self.strokes valueForKeyPath:@"unionOfArrays.self"];
    return [[MPPointCloud alloc] initWithName:self.name
                                           points:points
                                resampledToNumber:resampledPointCount
                                  normalizedScale:YES
                             differenceToCentroid:[MPPoint origin]];
}

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries
{
    NSMutableArray *strokeSequences = [NSMutableArray arrayWithCapacity:arrayOfDictionaries.count];
    for (NSDictionary *dict in arrayOfDictionaries)
        [strokeSequences addObject:[[MPStrokeSequence alloc] initWithDictionary:dict]];
    
    return strokeSequences;
}

- (BOOL)isEqual:(MPStrokeSequence *)object
{
    if (!object)
        return NO;
    
    if (![object isKindOfClass:[MPStrokeSequence class]])
        return NO;
    
    if (![self.name isEqualToString:object.name])
        return NO;
    
    return [self.strokes isEqual:object.strokes];
}

- (NSUInteger)hash
{
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + _name.hash;
    
    // FIXME: prevent mutating _strokes after the stroke sequence has been added to a stroke sequence database
    
    for (MPStroke *stroke in _strokes)
        result = prime * result + stroke.hash;
    
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<DollarStrokeSequence: name:%@ (%lu strokes) >",
            self.name,
            (unsigned long)self.strokeCount];
}

@end
