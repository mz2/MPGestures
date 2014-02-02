//
//  MPDollarStrokeSequence.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPStroke, MPPointCloud;

@interface MPStrokeSequence : NSObject

@property (readonly) NSString *name;

@property (readonly) NSArray *strokesArray;

@property (readonly) NSUInteger strokeCount;

/**
 * A signature for the stroke sequence.
 * A stroke sequence database should only contain a single stroke sequence with a matching signature.
 */
@property (readonly, copy) NSString *signature;

/**
 *  A string of format name-[first 4 bytes of signature].
 */
@property (readonly, copy) NSString *practicallyUniqueIdentifier;

/** A copy of all points in the stroke sequence, ordered by stroke and the point index in stroke. */
@property (readonly, copy) NSArray *points;

/** The bounding area around all the points in the sequence. */
@property (readonly) float boundingArea;

/** The average curvature between subsequent points in the sequence. */
@property (readonly) float averageCurvature;

/** Lengths of the strokes in the sequence combined. Distance between subsequent strokes is also treated as an additional length. */
@property (readonly) float length;

- (BOOL)containsStroke:(MPStroke *)stroke;

- (void)addStroke:(MPStroke *)stroke;

- (MPStroke *)lastStroke;

- (NSDictionary *)dictionaryRepresentation;

/**
 *  Stroke sequences have a natural sorting order based on case **sensitive** comparison of the stroke sequence names.
 */
- (NSComparisonResult)compare:(MPStrokeSequence *)other;

/**
 * Point cloud representation, optionally scaled and centered on its centroid.
 *
 * @param resampledPointCount If a positive integer, point cloud is resampled at the specified rate, and scale and transaltion normalised. If 0 passed, no resampling, scale, or translation normalisation is done.
 */
- (MPPointCloud *)pointCloudRepresentationWithResampleCount:(NSUInteger)resampledPointCount;

- (instancetype)initWithName:(NSString *)name strokes:(NSArray *)arrays;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithStrokeSequence:(MPStrokeSequence *)sequence;
- (instancetype)initWithName:(NSString *)name points:(NSArray *)points;

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end
