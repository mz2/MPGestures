//
//  MPSupervisedGestureRecognizer.m
//  MPGestures
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPSupervisedGestureRecognizer.h"

#import "MPStrokeSequenceDatabase.h"

#import <MPRandomForest/MPALGLIBDecisionForestClassifier.h>
#import <MPRandomForest/MPDataTable.h>
#import <MPRandomForest/MPIdentityTransformer.h>

#import "MPStrokeSequenceDimensionMapper.h"
#import "MPPointCloud.h"

@interface MPSupervisedGestureRecognizer ()
@property (readonly) MPStrokeSequenceDatabase *trainingDatabase;
@property (readonly) MPStrokeSequenceDatabase *referenceDatabase;
@end

@interface MPRandomForestGestureRecognizer ()
@property (readonly) MPALGLIBDecisionForestClassifier *classifier;
@property (readonly) MPStrokeSequenceDimensionMapper *dimensionMapper;
@end

@implementation MPSupervisedGestureRecognizer

- (id)init
{
    @throw [NSException exceptionWithName:@"MPAbstractClassException" reason:nil userInfo:nil];
    return nil;
}

- (instancetype)initWithTrainingDatabase:(MPStrokeSequenceDatabase *)trainingDatabase
                       referenceDatabase:(MPStrokeSequenceDatabase *)referenceDatabase
{
    self = [super init];
    if (self) {
        _trainingDatabase = trainingDatabase;
        _referenceDatabase = referenceDatabase;
    }
    return self;
}

- (void)addStrokeSequence:(MPStrokeSequence *)sequence {
    @throw [NSException exceptionWithName:@"MPAbstractMethodException" reason:nil userInfo:nil];
}

- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)sequence {
    @throw [NSException exceptionWithName:@"MPAbstractMethodException" reason:nil userInfo:nil];
}

@end

#pragma mark - Random forest gesture recognizer

@interface MPRandomForestGestureRecognizer ()
@property (readonly) id<MPTrainableDataSet> trainingDataSet;
@end

@implementation MPRandomForestGestureRecognizer

- (instancetype)initWithTrainingDatabase:(MPStrokeSequenceDatabase *)trainingDatabase
               referenceSequenceDatabase:(MPStrokeSequenceDatabase *)referenceDatabase
{
    self = [super initWithTrainingDatabase:trainingDatabase referenceDatabase:referenceDatabase];
    if (self) {
        id<MPStrokeSequenceDataSet> trainingSequenceDataset = [trainingDatabase dataSetRepresentation];
        
        NSArray *referenceSequences = [referenceDatabase.strokeSequenceSet.allObjects sortedArrayUsingSelector:@selector(compare:)];
        
        _dimensionMapper = [[MPStrokeSequenceDimensionMapper alloc] initWithDataSet:trainingSequenceDataset
                                                           referenceStrokeSequences:referenceSequences
                                                                       resampleRate:MPPointCloudDefaultResampleRate];
        
        _trainingDataSet = [_dimensionMapper mappedDataSet];
        
        _classifier = [[MPALGLIBDecisionForestClassifier alloc]
                       initWithTransformer:[[MPIdentityTransformer alloc] initWithDataSet:_trainingDataSet]
                       trainingData:_trainingDataSet];
    }
    return self;
}

@end