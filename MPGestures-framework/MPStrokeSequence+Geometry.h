//
//  MPStrokeSequence+Geometry.h
//  MPGestures
//
//  Created by Matias Piipari on 02/02/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPStrokeSequence.h"

@interface MPStrokeSequence (Geometry)

/** A copy of all points in the stroke sequence, ordered by stroke and the point index in stroke. */
@property (readonly, copy) NSArray *points;

/** The bounding area around all the points in the sequence. */
@property (readonly) float boundingArea;

/** The average curvature between subsequent points in the sequence. */
@property (readonly) float averageCurvature;

/** Lengths of the strokes in the sequence combined. Distance between subsequent strokes is also treated as an additional length. */
@property (readonly) float length;

/**
 *  The minimal distance of the stroke sequence with a template.
 *
 *  @param shapeB the template stroke sequence to compare this object to.
 *  @param rotate if YES, the input shape is rotated to fit the template shape at the optimal rotation.
 *  @param shapeC A pointer to a transformed shape that gives the shortest distance.
 *
 *  @return The Procrustes distance of the stroke sequence with a template.
 */
- (double)minimalProcrustesDistanceWithStrokeSequence:(MPStrokeSequence *)shapeB
                      rotateTransformedStrokeSequence:(BOOL)rotate
                            transformedStrokeSequence:(MPStrokeSequence **)shapeC;

@end
