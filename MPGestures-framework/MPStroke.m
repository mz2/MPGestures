//
//  Stroke.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPStroke.h"
#import "MPPoint.h"

@interface MPStroke ()
@property (nonatomic, strong) NSMutableArray *points;
@end

@implementation MPStroke

- (instancetype)init {
    if (self = [super init])
    {
        _points = [NSMutableArray arrayWithCapacity:128];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init])
    {
        _points = [[MPPoint pointsWithArrayOfDictionaries:dictionary[@"points"]] mutableCopy];
    }
    
    return self;
}

- (instancetype)initWithPoints:(NSArray *)points {
    self = [self init];
    if (self) {
        for (MPPoint *p in points) {
            // FIXME: don't be silly with converting between MPPoint and CGPoint needlessly.
            [self addPoint:p.CGPointValue identifier:[p.id unsignedIntegerValue]];
        }
    }
    
    return self;
}

- (void)addPoint:(CGPoint)p identifier:(NSUInteger)i
{
    assert(_points);
    MPPoint *dp = [[MPPoint alloc] initWithId:@(i) x:p.x y:p.y];
    [_points addObject:dp];
}

- (NSArray *)pointsArray
{
    return [_points copy];
}

-(NSDictionary *)dictionaryRepresentation
{
    return @{ @"points" : [_points valueForKey:@"dictionaryRepresentation"] };
}

+ (NSArray *)strokesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries
{
    NSMutableArray *strokes = [NSMutableArray arrayWithCapacity:arrayOfDictionaries.count];
    for (NSDictionary *dict in arrayOfDictionaries)
        [strokes addObject:[[MPStroke alloc] initWithDictionary:dict]];
    
    return strokes;
}


- (BOOL)isEqual:(MPStroke *)object
{
    if (!object)
        return NO;
    
    if (![object isKindOfClass:[MPStroke class]])
        return NO;
    
    if (self.points.count != object.points.count)
        return NO;
    
    float dist = [MPPoint leastSquaresEuclideanDistanceOfPoints:self.points withPoints:object.points];
    
    return dist < 0.0001;
}

- (NSUInteger)hash
{
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    
    // FIXME: prevent mutating points once it's been added to a stroke
    for (MPPoint *p in _points)
        result = prime * result + p.hash;
    
    return result;
}

@end