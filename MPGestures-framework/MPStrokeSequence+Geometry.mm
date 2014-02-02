//
//  MPStrokeSequence+Geometry.m
//  MPGestures
//
//  Created by Matias Piipari on 02/02/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPStrokeSequence+Geometry.h"

#import <ALGLIB/ALGLIB.h>

#import <math.h>
#import <vector>
#import <stdlib.h>
#import <stdio.h>
#import <string.h>

#ifndef PSQDeg2Rad
#define PSQDeg2Rad(X) (X * M_PI/180.0f)
#endif

#ifndef PSQRad2Deg
#define PSQRad2Deg(X) (180.0f * X/M_PI)
#endif
@implementation MPStrokeSequence (Geometry)

- (NSPointArray)pointArrayRepresentation
{
    NSArray *points = self.points;
    NSUInteger cnt = points.count;
    NSPointArray parray = (NSPointArray)malloc(cnt * sizeof(NSPoint));
    
    for (NSUInteger i = 0; i < cnt;i++)
        parray[i] = [points[i] pointValue];
    
    return parray;
}

- (NSArray *)points {
    return [[self.strokesArray
             valueForKey:@"pointsArray"]
            valueForKeyPath:@"@unionOfArrays.self"];
}

+ (NSRect)boundsForPoints:(NSArray *)points
{
    if (points.count < 3) return NSZeroRect;
    
    CGPoint p = [points.firstObject CGPointValue];
    NSRect unionRect = NSMakeRect(p.x, p.y, 0.001f, 0.001f);
    for (NSUInteger i = 1, cnt = points.count; i < cnt; i++)
    {
        p = [points[i] pointValue];
        unionRect = NSUnionRect(unionRect, NSMakeRect(p.x, p.y, 0.001f, 0.001f));
    }
    
    return unionRect;
}

- (float)boundingArea {
    return [self.class boundingAreaForPoints:self.points];
}

+ (float)boundingAreaForPoints:(NSArray *)points
{
    NSRect bounds = [self boundsForPoints:points];
    return bounds.size.width * bounds.size.height;
}

+ (CGPoint)normalizedVector:(CGPoint)v {
    CGFloat len = sqrtf(v.x*v.x + v.y*v.y);
    v.x = v.x/len;
    v.y = v.y/len;
    return v;
}

+ (CGPoint)vectorFromPoint:(CGPoint)pt1 toPoint:(CGPoint)pt2 {
    return NSMakePoint(pt2.x - pt1.x, pt2.y - pt1.y);
}

+ (float)angleBetweenPoint:(CGPoint)pt1
                  andPoint:(CGPoint)pt2
               centerPoint:(CGPoint)c
{
    CGPoint v1 = [self normalizedVector:[self vectorFromPoint:pt1 toPoint:c]];
    CGPoint v2 = [self normalizedVector:[self vectorFromPoint:pt2 toPoint:c]];
    return atan2(v2.y, v2.x) - atan2(v1.y,v1.x);
}

- (float)averageCurvature {
    return [[self class] averageCurvatureBetweenSubsequentPoints:self.points];
}

+ (CGFloat)averageCurvatureBetweenSubsequentPoints:(NSArray *)points
{
    CGFloat angle = 0.0f;
    
    NSUInteger edgeCount = points.count - 2;
    
    if (edgeCount < 3) return 0.0f;
    
    for (NSUInteger i = 0, cnt = points.count - 2; i < cnt; i++)
    {
        NSPoint p1 = [points[i] pointValue];
        NSPoint p2 = [points[i + 1] pointValue];
        NSPoint p3 = [points[i + 2] pointValue];
        angle += fabsf([self angleBetweenPoint:p1 andPoint:p3 centerPoint:p2]);
    }
    
    return angle / (CGFloat)edgeCount;
}

- (float)length
{
    NSArray *points = self.points;
    CGFloat len = 0.0f;
    for (NSUInteger i = 0, cnt = points.count - 1; i < cnt; i++)
    {
        NSPoint p1 = [points[i] pointValue];
        NSPoint p2 = [points[i+1] pointValue];
        CGPoint v = [[self class] vectorFromPoint:p1 toPoint:p2];
        len += (v.x * v.x + v.y * v.y);
    }
    return len;
}

@end
