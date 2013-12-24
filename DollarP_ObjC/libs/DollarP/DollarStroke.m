//
//  Stroke.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "DollarStroke.h"
#import "DollarPoint.h"

@interface DollarStroke ()
@property (nonatomic, strong) NSMutableArray *points;
@end

@implementation DollarStroke

- (instancetype)init
{
    if (self = [super init])
    {
        _points = [NSMutableArray arrayWithCapacity:128];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _points = [[DollarPoint pointsWithArrayOfDictionaries:dictionary[@"points"]] mutableCopy];
    }
    
    return self;
}

- (void)addPoint:(CGPoint)p identifier:(NSUInteger)i
{
    assert(_points);
    DollarPoint *dp = [[DollarPoint alloc] initWithId:@(i) x:p.x y:p.y];
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
        [strokes addObject:[[DollarStroke alloc] initWithDictionary:dict]];
    
    return strokes;
}

@end