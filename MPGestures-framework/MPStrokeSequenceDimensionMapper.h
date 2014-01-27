//
//  MPStrokeSequenceDimensionMapper.h
//  MPGestures
//
//  Created by Matias Piipari on 26/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <MPRandomForest/MPNamedColumnDimensionMapper.h>

@protocol MPTrainableDataSet, MPStrokeSequenceDataSet;

@interface MPStrokeSequenceDimensionMapper : MPNamedColumnDimensionMapper

/**
 *  The input dataset must have two columns: a label, and a stroke sequence.
 */
- (instancetype)initWithDataSet:(id<MPStrokeSequenceDataSet>)dataSet
       referenceStrokeSequences:(NSArray *)referenceStrokeSequences
                   resampleRate:(NSUInteger)resampleRate;

@property (readwrite) NSUInteger pointCloudResampleRate;

@end
