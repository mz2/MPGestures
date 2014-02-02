//
//  MPStrokeSequence+Geometry.m
//  MPGestures
//
//  Created by Matias Piipari on 02/02/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPStrokeSequence+Geometry.h"

#include <opencv2/core/core.hpp>
#include <OpenCV2/objdetect/objdetect.hpp>
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

#pragma mark - Representations

- (NSPointArray)pointArrayRepresentation
{
    NSArray *points = self.points;
    NSUInteger cnt = points.count;
    NSPointArray parray = (NSPointArray)malloc(cnt * sizeof(NSPoint));
    
    for (NSUInteger i = 0; i < cnt;i++)
        parray[i] = [points[i] pointValue];
    
    return parray;
}

- (std::vector<cv::Point2f> *)stdPointVectorRepresentation
{
    NSArray *points = self.points;
    NSUInteger pointCount = points.count;
    std::vector<cv::Point2f> *vec = new std::vector<cv::Point2f>(pointCount);
    
    for (NSUInteger i = 0; i < pointCount; i++)
    {
        NSPoint pn = [points[i] CGPointValue];
        cv::Point2f v = cv::Point2f(pn.x, pn.y);
        vec->push_back(v);
    }
    
    return vec;
}


- (cv::Seq<cv::Point2f> *)cvSeqRepresentation
{
    cv::Seq<cv::Point2f> *seq = new cv::Seq<cv::Point2f>();
    
    NSArray *points = self.points;
    NSUInteger cnt = points.count;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        NSPoint pn = [points[i] pointValue];
        seq->push_back(cv::Point2f(pn.x, pn.y));
    }
    
    return seq;
}

- (std::vector<cv::Vec2f> *)stdVectorRepresentation
{
    NSArray *points = self.points;
    NSUInteger pointCount = points.count;
    std::vector<cv::Vec2f> *vec = new std::vector<cv::Vec2f>(pointCount);
    
    for (NSUInteger i = 0; i < pointCount; i++)
    {
        NSPoint pn = [points[i] pointValue];
        cv::Vec2f v = cv::Point2f(pn.x, pn.y);
        vec->push_back(v);
    }
    
    return vec;
}

- (cv::Mat *)cvMatRepresentation
{
    std::vector<cv::Vec2f> *vecRep = [self stdVectorRepresentation];
    cv::Mat *mat = new cv::Mat(*vecRep, false);
    return mat;
}

- (cv::Point2f *)cvPointArrayRepresentation
{
    NSArray *points = self.points;
    NSUInteger cnt = self.points.count;
    cv::Point2f *seq = (cv::Point2f *)malloc(sizeof(cv::Point2f) * cnt);
    
    for (NSUInteger i = 0; i < cnt; i++)
    {
        NSPoint p = [points[i] pointValue];
        cv::Point2f cvp;
        cvp.x = p.x;
        cvp.y = p.y;
        seq[i] = cvp;
    }
    
    return seq;
}

#pragma mark -

- (CGFloat)contourArea
{
    CvMemStorage *storage;
    storage = cvCreateMemStorage();
    
    std::vector<cv::Point2f> *seq = [self stdPointVectorRepresentation];
    double d = cv::contourArea(*seq);
    cvReleaseMemStorage(&storage);
    
    return (CGFloat)d;
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
