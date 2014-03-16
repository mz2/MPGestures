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
#import "MPStrokeSequence+Geometry.h"

@interface MPStrokeSequenceDimensionMapper ()
@property (readonly) NSArray *referenceStrokeSequences;
@property (readonly) NSArray *referencePointClouds;

@property (readwrite) BOOL includePointClouds;
@property (readwrite) BOOL includeProcrustesAnalysis;
@property (readwrite) BOOL imageMoment;

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
        
        self.includePointClouds = YES;
        self.includeProcrustesAnalysis = NO;
        
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
    assert(_referenceStrokeSequences.count == _referencePointClouds.count);

    NSMutableArray *output = [NSMutableArray array];
    if (self.includePointClouds)
    {
        MPPointCloud *valueCloud = [value pointCloudRepresentationWithResampleCount:_pointCloudResampleRate];
        for (MPPointCloud *cloud in _referencePointClouds) {
            float score = [[MPDollarPointCloudRecognizer class] scoreForGreedyCloudMatchOfPointCloud:valueCloud
                                                                                        withTemplate:cloud
                                                                                      atResamplerate:_pointCloudResampleRate];
            [output addObject:@(score)];
        }
    }
    
    if (self.includeProcrustesAnalysis)
    {
        MPStrokeSequence *resampledValue = [[MPStrokeSequence alloc] initWithStrokeSequence:value resampleCount:_pointCloudResampleRate];
        
        for (MPStrokeSequence *refSeq in _referenceStrokeSequences) {
            MPStrokeSequence *transformedSequence = nil;
            
            MPStrokeSequence *resampledRefSeq = [[MPStrokeSequence alloc] initWithStrokeSequence:refSeq resampleCount:_pointCloudResampleRate];
            
            float score = [resampledValue minimalProcrustesDistanceWithStrokeSequence:resampledRefSeq
                                                      rotateTransformedStrokeSequence:YES
                                                            transformedStrokeSequence:&transformedSequence];
            
            [output addObject:@(score)];
        }
    }
    
    return [output copy];
}

- (NSArray *)mappedColumnTypesForStrokeSequence {
    assert(_referenceStrokeSequences);
    NSMutableArray *vals = [NSMutableArray arrayWithCapacity:_referenceStrokeSequences.count];
    
    if (self.includePointClouds)
    {
        for (NSUInteger i = 0; i < _referenceStrokeSequences.count; i++)
            [vals addObject:@(MPColumnTypeFloatingPoint)];
    }
    
    if (self.includeProcrustesAnalysis)
    {
        for (NSUInteger i = 0; i < _referenceStrokeSequences.count; i++)
            [vals addObject:@(MPColumnTypeFloatingPoint)];
    }
    
    return [vals copy];
}

- (NSArray *)mappedColumnNamesForStrokeSequence {
    assert(_referenceStrokeSequences);
    
    NSArray *identifiers = [_referenceStrokeSequences valueForKey:@"practicallyUniqueIdentifier"];
    NSMutableArray *columnNames = [NSMutableArray arrayWithCapacity:identifiers.count * 2];

    if (self.includePointClouds)
    {
        for (NSString *identifier in identifiers)
            [columnNames addObject:[identifier stringByAppendingString:@"-dollarP"]];
    }
    
    if (self.includeProcrustesAnalysis)
    {
        for (NSString *identifier in identifiers)
            [columnNames addObject:[identifier stringByAppendingString:@"-procrustes"]];
    }
    
    return [columnNames copy];
}

- (NSUInteger)mappedDimensionalityForStrokeSequence {
    NSUInteger count = 0;
    
    if (self.includePointClouds)
        count += _referenceStrokeSequences.count;

    if (self.includeProcrustesAnalysis)
        count += _referenceStrokeSequences.count;
    
    return count;
}

@end