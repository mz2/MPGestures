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

#import "MPStroke.h"
#import "MPPoint.h"

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

- (alglib::real_2d_array *)real2DArrayRepresentation
{
    NSArray *points = self.points;
    NSUInteger cnt = self.points.count;
    alglib::real_2d_array *array = new alglib::real_2d_array();
    array->setlength(cnt, 2);
    for (NSUInteger i = 0; i < cnt; i++)
    {
        NSPoint p = [points[i] pointValue];
        (*(array))(i,0) = p.x;
        (*(array))(i,1) = p.y;
    }
    return array;
}

#pragma mark - Transformations

- (MPStrokeSequence *)strokeSequenceTranslatedWithVector:(CGPoint)vector
{
    MPStrokeSequence *newShape = [[MPStrokeSequence alloc] initWithName:self.name points:@[]];
    
    for (MPStroke *stroke in self.strokesArray) {
        
        MPStroke *newStroke = [[MPStroke alloc] initWithPoints:@[]];
        for (MPPoint *point in stroke.pointsArray) {
            NSPoint p = [point CGPointValue];
            CGPoint v = [[self class] vectorFromPoint:vector toPoint:p];
            [newStroke addPoint:v identifier:[point.id unsignedIntegerValue]];
        }
        [newShape addStroke:newStroke];
    }
    
    return newShape;
}

- (MPStrokeSequence *)strokeSequenceScaledWithVector:(CGPoint)vector
{
    MPStrokeSequence *newShape = [[MPStrokeSequence alloc] initWithName:self.name points:@[]];
    
    for (MPStroke *stroke in self.strokesArray) {
        MPStroke *newStroke = [[MPStroke alloc] initWithPoints:@[]];
        for (MPPoint *point in stroke.pointsArray) {
            CGPoint p = [point CGPointValue];
            p.x = p.x * vector.x;
            p.y = p.y * vector.y;
            [newStroke addPoint:p identifier:[point.id unsignedIntegerValue]];
        }
    }
    
    return newShape;
}

- (MPStrokeSequence *)strokeSequenceWithVertexIndexOffset:(NSUInteger)offset
{
    if (offset == 0) return self;
    
    NSArray *points = self.points;
    NSUInteger cnt = points.count;
    MPStrokeSequence *shape = [[MPStrokeSequence alloc] initWithName:self.name points:@[]];
    MPStroke *stroke = [[MPStroke alloc] initWithPoints:@[]];
    
    for (NSUInteger i = 0; i < cnt; i++)
    {
        NSUInteger vi = i + offset;
        if (vi >= cnt) vi = vi - cnt; //caveman's ring buffer

        MPPoint *point = points[vi];
        [stroke addPoint:[self.points[vi] CGPointValue] identifier:[point.id unsignedIntegerValue]];
    }
    
    assert (self.points.count == shape.points.count);
    return shape;
}

#pragma mark - Geometric properties

- (NSArray *)points {
    return [[self.strokesArray
             valueForKey:@"pointsArray"]
            valueForKeyPath:@"@unionOfArrays.self"];
}


- (NSPoint)centerPoint
{
    CGFloat avgX = .0f;
    CGFloat avgY = .0f;
    
    NSArray *points = self.points;
    NSUInteger cnt = points.count;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        NSPoint p = [points[i] pointValue];
        avgX = avgX + p.x;
        avgY = avgY + p.y;
    }
    
    avgX = avgX / (CGFloat)cnt;
    avgY = avgY / (CGFloat)cnt;
    
    return NSMakePoint(avgX, avgY);
}

- (CGFloat)contourArea
{
    CvMemStorage *storage;
    storage = cvCreateMemStorage();
    
    std::vector<cv::Point2f> *seq = [self stdPointVectorRepresentation];
    double d = cv::contourArea(*seq);
    cvReleaseMemStorage(&storage);
    
    return (CGFloat)d;
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

- (MPStrokeSequence *)strokeSequenceRotatedByMatrix:(alglib::real_2d_array)rotationMatrix
{
    alglib::real_2d_array *arrayRep = [self real2DArrayRepresentation];
    
    assert(rotationMatrix.rows() == arrayRep->cols());
    
    alglib::real_2d_array target = alglib::real_2d_array();
    target.setlength(arrayRep->rows(), arrayRep->cols());
    
    alglib::rmatrixgemm(arrayRep->rows(),
                        rotationMatrix.cols(),
                        arrayRep->cols(), 1.0,
                        *arrayRep     , 0, 0, 0,
                        rotationMatrix, 0, 0, 0,
                        0.0, target,
                        0, 0);
    //std::cerr << "arrayrep: " << arrayRep->tostring(2) << "\n";
    //std::cerr << "target  : " << target.tostring(2)    << "\n";
    delete arrayRep;
    
    //assert(cnt == target.rows());
    
    MPStrokeSequence *targetShape
        = [[MPStrokeSequence alloc] initWithName:self.name points:@[]];
    
    NSUInteger i = 0;
    for (MPStroke *stroke in self.strokesArray) {
        MPStroke *s = [[MPStroke alloc] init];
        
        for (MPPoint *point in stroke.pointsArray) {
            CGPoint p = CGPointMake(target(i,0), target(i,1));
            [s addPoint:p identifier:[point.id unsignedIntegerValue]];
            i++;
        }
        
        [targetShape addStroke:s];
    }
    
    return targetShape;
}

#pragma mark -
#pragma mark Primitives
#pragma mark -
#pragma mark Shape descriptors

- (float)matchToTemplate:(MPStrokeSequence *)templateShape
{
    CvMemStorage *storage;
    storage = cvCreateMemStorage();
    
    cv::Mat *seq = [self cvMatRepresentation];
    cv::Mat *templateSeq = [templateShape cvMatRepresentation];
    
    if (!templateSeq)
    {
        cvReleaseMemStorage(&storage);
        return -1.0f;
    }
    
    double matchFactor = cv::matchShapes(*seq, *templateSeq, 1, 0.0f);
    cvReleaseMemStorage(&storage);
    return matchFactor;
}

/* trace(M^T x M) */
double squaredFrobeniusMatrixNorm(alglib::real_2d_array matrix);

double squaredFrobeniusMatrixNorm(alglib::real_2d_array matrix)
{
    alglib::real_2d_array target = alglib::real_2d_array();
    target.setlength(matrix.cols(), matrix.cols());
    
    alglib::rmatrixgemm(matrix.cols(), matrix.cols(), matrix.rows(), 1.0,
                        matrix, 0, 0, 1, //transpose
                        matrix, 0, 0, 0,
                        0.0,
                        target, 0, 0);
    
    assert(target.cols() == target.rows());
    
    double d = 0.0f;
    NSUInteger size = target.cols();
    for (NSUInteger i = 0; i < size; i++) d += target(i,i);
    
    return d;
}

- (double)minimalProcrustesDistanceWithStrokeSequence:(MPStrokeSequence *)shapeB
                                             rotation:(alglib::real_2d_array **)rotation
                                          translation:(alglib::real_2d_array **)translation
                                                scale:(NSNumber **)scaleFactor
{
    MPStrokeSequence *shapeA = self;
    
    NSArray *shapeAPoints = shapeA.points;
    NSUInteger cnt = shapeAPoints.count;
    
    NSPoint aCenter = [shapeA centerPoint];
    alglib::real_2d_array x1mu = alglib::real_2d_array();
    x1mu.setlength(1, 2);
    x1mu(0, 0) = aCenter.x;
    x1mu(0, 1) = aCenter.y;
    
    NSPoint bCenter = [shapeB centerPoint];
    alglib::real_2d_array x2mu = alglib::real_2d_array();
    x2mu.setlength(1, 2);
    x2mu(0, 0) = bCenter.x;
    x2mu(0, 0) = bCenter.y;
    
    alglib::real_2d_array *x1centered = [[shapeA strokeSequenceTranslatedWithVector:aCenter] real2DArrayRepresentation];
    alglib::real_2d_array *x2centered = [[shapeB strokeSequenceTranslatedWithVector:bCenter] real2DArrayRepresentation];
    alglib::real_2d_array *x1 = [shapeA real2DArrayRepresentation];
    alglib::real_2d_array *x2 = [shapeB real2DArrayRepresentation];
    
    alglib::real_2d_array x1tx2 = alglib::real_2d_array();
    x1tx2.setlength(2, 2);
    
    assert(x1centered->rows() == x2centered->rows());
    
    alglib::real_2d_array x1centeredT = alglib::real_2d_array();
    x1centeredT.setlength(x1centered->cols(), x1centered->rows());
    
    alglib::rmatrixtranspose(x1centered->rows(), x1centered->cols(),
                             *x1centered, 0, 0,
                             x1centeredT, 0, 0);
    
    alglib::rmatrixgemm(x1centeredT.rows(), x2centered->cols(), cnt,
                        1.0,
                        x1centeredT, 0, 0, 0, //0, 0, 1 row and col offsets of 0,0, 1 = transpose
                        *x2centered, 0, 0, 0, //0, 0, 0 row and col offsets of 0,0, 0 = use values as is
                        0.0, // 0.0f is added to output matrix C (gives x1tx2)
                        x1tx2,
                        0, 0); //row and column offsets
    
    //std::cerr << "x1tx2: " << x1tx2.tostring(0) << "\n";
    
    alglib::real_2d_array u  = alglib::real_2d_array();
    u.setlength(2, 2);
    
    alglib::real_2d_array vt = alglib::real_2d_array();
    vt.setlength(2, 2);
    
    alglib::real_1d_array w  = alglib::real_1d_array();
    w.setlength(2);
    
    alglib::rmatrixsvd(x1tx2,
                       2, 2, //rows x cols in x1tx2
                       2, //U needed
                       2, //VT needed
                       2, //higher mem, faster solution
                       w, u, vt);
    
    /* Let's compute scaling factor beta first, because it's needed in the x1r computing. */
    double traceW = 0.0f;
    for (NSUInteger i = 0; i < w.length(); i++) traceW += w(i);
    double beta = traceW / squaredFrobeniusMatrixNorm(*x1centered);
    
    //R = U x V^T
    alglib::real_2d_array *r = new alglib::real_2d_array();
    assert(u.rows() == vt.cols());
    r->setlength(u.rows(), vt.cols());
    
    /*
     std::cerr << "u    : " <<  u.tostring(2)  << "\n";
     std::cerr << "w    : " <<  w.tostring(2)  << "\n";
     std::cerr << "vt   : " << vt.tostring(2)  << "\n";
     std::cerr << "beta : " << beta            << "\n";
     */
    
    alglib::rmatrixgemm(u.rows(), vt.cols(), u.cols(),
                        1.0f,
                        u,  0, 0, 0,
                        vt, 0, 0, 0,
                        0.0f,
                        *r,
                        0, 0);
    
    //std::cerr << "r    :" << r ->tostring(3) << "\n";
    
    alglib::real_2d_array betax1r = alglib::real_2d_array();
    betax1r.setlength(x1->rows(), r->cols());
    
    alglib::rmatrixgemm(x1->rows(), r->cols(), x1->cols(),
                        beta,
                        *x1, 0, 0, 0,
                        *r,  0, 0, 0,
                        0.0,
                        betax1r,
                        0, 0);
    
    //std::cerr << "betax1r:" << betax1r.tostring(0) << "\n";
    
    alglib::real_2d_array rx1 = alglib::real_2d_array();
    rx1.setlength(r->rows(), x1mu.cols());
    
    alglib::rmatrixgemm(r->rows(), x1mu.cols(), r->cols(),
                        1.0,
                        *r,   0, 0, 0,
                        x1mu, 0, 0, 0,
                        0.0,
                        rx1,
                        0, 0);
    
    alglib::real_2d_array *mu = new alglib::real_2d_array();
    mu->setlength(1, 2);
    (*mu)(0,0) = (*x2)(0, 0) - rx1(0, 0);
    (*mu)(0,1) = (*x2)(0, 1) - rx1(0, 1);
    
    /* x2 - betax1r can be done in place because x2 won't be needed after this point */
    
    assert(x2->rows() == betax1r.rows());
    //assert(x2->cols() == betax1r.cols());
    
    //std::cerr << "x1c  : " << x1centered->tostring(0) << "\n";
    //std::cerr << "x2c  : " << x2centered->tostring(0) << "\n";
    
    for (NSUInteger i = 0, x2rows = x2->rows(); i < x2rows; i++)
        for (NSUInteger j = 0, x2cols = x2->cols(); j < x2cols; j++)
            (*x2)(i,j) = (*x2)(i,j) - betax1r(i,j);
    
    double pr = sqrt(squaredFrobeniusMatrixNorm(*x2));
    
    /*
     std::cerr << "R    : " << r->tostring(2) << "\n";
     std::cerr << "mu   : " << (*mu)(0,0) << "," << (*mu)(0,1) << "\n";
     std::cerr << "beta : " << beta << "\n";
     std::cerr << "pr   :" << pr << "\n";
     */
    
    *rotation = r;
    *translation = mu;
    
    *scaleFactor = [NSNumber numberWithFloat:beta];
    
    delete x1;
    delete x2;
    delete x1centered;
    delete x2centered;
    
    return pr;
}

- (double)minimalProcrustesDistanceWithStrokeSequence:(MPStrokeSequence *)shapeB
                      rotateTransformedStrokeSequence:(BOOL)rotate
                            transformedStrokeSequence:(MPStrokeSequence **)shapeC
{
    alglib::real_2d_array *rot = NULL;
    alglib::real_2d_array *trans = NULL;
    NSNumber *scaleP = nil;
    
    NSPoint bCentreP = [shapeB centerPoint];
    
    
    //NSLog(@"B            : %@", [shapeB vertices]);
    
    shapeB = [shapeB strokeSequenceTranslatedWithVector:bCentreP];
    //NSLog(@"B translated : %@", [shapeB vertices]);
    
    double distance = [self minimalProcrustesDistanceWithStrokeSequence:shapeB rotation:&rot translation:&trans scale:&scaleP];
    
    double scale = [scaleP doubleValue];
    CGPoint scaleV = CGPointMake(scale, scale);
    //scaleV.x = 1.0 / scaleV.x;
    //scaleV.y = 1.0 / scaleV.y;
    
    NSPoint centreP = [self centerPoint];
    
    MPStrokeSequence *transformedShape = [self strokeSequenceTranslatedWithVector:centreP];
    
    //NSLog(@"A centered  : %@", [transformedShape vertices]);
    
    //PSQVector transV = NSMakePoint((*trans)(0,0), (*trans)(0,1));
    transformedShape = [transformedShape strokeSequenceScaledWithVector:scaleV];
    //NSLog(@"A scaled    : %@", [transformedShape vertices]);
    
    if (rotate)
    {
        transformedShape = [transformedShape strokeSequenceRotatedByMatrix:*rot];
    }
    //NSLog(@"A rotated   : %@", [transformedShape vertices]);
    
    bCentreP.x *= -1.0f;
    bCentreP.y *= -1.0f;
    transformedShape = [transformedShape strokeSequenceTranslatedWithVector:bCentreP];
    //NSLog(@"A translated: %@", [transformedShape vertices]);
    
    /*
     centreP.x *= -1.0f;
     centreP.y *= -1.0f;
     transformedShape = [transformedShape shapeTranslatedWithVector:centreP];
     */
    
    //NSLog(@"OUTPUT SHAPE: %@", [transformedShape vertices]);
    
    *shapeC = transformedShape;
    
    delete rot;
    delete trans;
    return distance;
}

- (double)minimalProcrustesDistanceWithStrokeSequence:(MPStrokeSequence *)shapeB
                            transformedStrokeSequence:(MPStrokeSequence **)shapeC
                      rotateTransformedStrokeSequence:(BOOL)rotate
                         optimalVertexOffset:(NSNumber **)vertexOffset
{
    MPStrokeSequence *minShape = nil;
    CGFloat minScore = DBL_MAX;
    NSUInteger minVertexOffset = 0;
    
    NSUInteger cnt = shapeB.points.count;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        MPStrokeSequence *transShape = nil;
        MPStrokeSequence *shapeWithVertexOffset = [shapeB strokeSequenceWithVertexIndexOffset:i];
        double score = [self minimalProcrustesDistanceWithStrokeSequence:shapeWithVertexOffset
                                         rotateTransformedStrokeSequence:rotate
                                               transformedStrokeSequence:&transShape];
        
        //NSLog(@"Score: %.2f (offset: %lu)", (CGFloat)score, i);
        if (score < minScore)
        {
            minScore = score;
            minShape = transShape;
            minVertexOffset = i;
        }
    }
    
    //NSLog(@"Minimum score: %.2f, vertex offset: %lu", minScore, minVertexOffset);
    
    *shapeC = minShape;
    *vertexOffset = [NSNumber numberWithUnsignedInteger:minVertexOffset];
    
    return minScore;
}

@end