//
//  MPStrokeSequenceDimensionMapper.m
//  MPGestures
//
//  Created by Matias Piipari on 26/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPStrokeSequenceDimensionMapper.h"
#import "MPStrokeSequenceDatabase.h"

#import <MPRandomForest/MPDataSet.h>

#import "MPDollarPointCloudRecognizer.h"
#import "MPStrokeSequenceRecognition.h"
#import "MPPointCloud.h"
#import "MPStrokeSequence.h"

@interface MPStrokeSequenceDimensionMapper ()
@property (readonly) NSArray *referenceStrokeSequences;
@property (readonly) NSArray *referencePointClouds;
@end

@implementation MPStrokeSequenceDimensionMapper

- (instancetype)initWithDataSet:(id<MPStrokeSequenceDataSet>)dataSet
       referenceStrokeSequences:(NSArray *)referenceStrokeSequences
                   resampleRate:(NSUInteger)resampleRate {
    self = [super initWithDataSet:dataSet];
    if (self) {
        assert([[dataSet nameForColumn:1] isEqualToString:MPCategoryNameStrokeSequenceLabel]);
        assert([dataSet typeForColumn:1] == MPColumnTypeCategorical);
        assert([[dataSet nameForColumn:0] isEqualToString:MPColumnNameStrokeSequenceObject]);
        assert([dataSet typeForColumn:0] == MPColumnTypeCustomObject);
        
        _pointCloudResampleRate = resampleRate;
        assert(resampleRate > 8);

        _referenceStrokeSequences = referenceStrokeSequences;
        assert(_referenceStrokeSequences);
        
        NSMutableArray *pointClouds = [NSMutableArray arrayWithCapacity:_referenceStrokeSequences.count];
        for (MPStrokeSequence *seq in referenceStrokeSequences) {
            MPPointCloud *pointCloud = [seq pointCloudRepresentationWithResampleCount:_pointCloudResampleRate];
            [pointClouds addObject:pointCloud];
        }
        _referencePointClouds = [pointClouds copy];
    }
    return self;
}

#pragma mark - The label field mapping

- (NSArray *)mappedStrokeSequenceLabelValuesForDatumValue:(id)value {
    return @[value];
}

- (NSArray *)mappedColumnTypesForStrokeSequenceLabel {
    return @[@(MPColumnTypeCategorical)];
}

- (NSArray *)mappedColumnNamesForStrokeSequenceLabel {
    return @[MPColumnNameStrokeSequenceLabel];
}

- (NSUInteger)mappedDimensionalityForStrokeSequenceLabel {
    return 1;
}

#pragma mark - The stroke sequence field mapping

- (NSArray *)mappedStrokeSequenceValuesForDatumValue:(MPStrokeSequence *)value {
    assert(_referenceStrokeSequences);
    MPPointCloud *valueCloud = [value pointCloudRepresentationWithResampleCount:_pointCloudResampleRate];
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:_referenceStrokeSequences.count];
    for (MPPointCloud *cloud in _referencePointClouds) {
        float score = [[MPDollarPointCloudRecognizer class] scoreForGreedyCloudMatchOfPointCloud:valueCloud
                                                                                    withTemplate:cloud
                                                                                  atResamplerate:_pointCloudResampleRate];
        [output addObject:@(score)];
    }
    return [output copy];
}

- (NSArray *)mappedColumnTypesForStrokeSequence {
    assert(_referenceStrokeSequences);
    NSMutableArray *vals = [NSMutableArray arrayWithCapacity:_referenceStrokeSequences.count];
    for (NSUInteger i = 0; i < _referenceStrokeSequences.count; i++)
        [vals addObject:@(MPColumnTypeFloatingPoint)];
    
    return [vals copy];
}

- (NSArray *)mappedColumnNamesForStrokeSequence {
    assert(_referenceStrokeSequences);
    return [_referenceStrokeSequences valueForKey:@"practicallyUniqueIdentifier"];
}

- (NSUInteger)mappedDimensionalityForStrokeSequence {
    return _referenceStrokeSequences.count;
}

@end