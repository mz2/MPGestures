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

#import "MPStrokeSequenceRecognition.h"
#import "MPStrokeSequence.h"

#import <MPRandomForest/NSArray+MaxValue.h>

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

- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)sequence {
    @throw [NSException exceptionWithName:@"MPAbstractMethodException" reason:nil userInfo:nil];
}

@end

#pragma mark - Random forest gesture recognizer

@interface MPRandomForestGestureRecognizer ()
@property (readonly) id<MPTrainableDataSet> trainingDataSet;
@property (readonly) NSArray *referenceStrokeSequences;
@property (readwrite, getter = isTrained) BOOL trained;
@property (readwrite) NSUInteger strokeResampleRate;
@end

@implementation MPRandomForestGestureRecognizer

- (instancetype)initWithTrainingDatabase:(MPStrokeSequenceDatabase *)trainingDatabase
               referenceSequenceDatabase:(MPStrokeSequenceDatabase *)referenceDatabase
{
    self = [super initWithTrainingDatabase:trainingDatabase referenceDatabase:referenceDatabase];
    if (self) {
        _strokeResampleRate = MPPointCloudDefaultResampleRate;
        
        id<MPStrokeSequenceDataSet> trainingSequenceDataset = [trainingDatabase dataSetRepresentation];
        
        _referenceStrokeSequences = [referenceDatabase.strokeSequenceSet.allObjects sortedArrayUsingSelector:@selector(compare:)];
        
        _dimensionMapper
            = [[MPStrokeSequenceDimensionMapper alloc] initWithDataSet:trainingSequenceDataset
                                              referenceStrokeSequences:_referenceStrokeSequences
                                                          resampleRate:_strokeResampleRate];
        
        _trainingDataSet = [_dimensionMapper mappedDataSet];
        
        _classifier = [[MPALGLIBDecisionForestClassifier alloc]
                       initWithTransformer:[[MPIdentityTransformer alloc] initWithDataSet:_trainingDataSet]
                       trainingData:_trainingDataSet];
    }
    return self;
}

- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq {
    // FIXME: don't require creating a database just for the sake of creating a dataset representation?
    MPStrokeSequenceDatabase *seqDB = [[MPStrokeSequenceDatabase alloc] initWithIdentifier:seq.name strokeSequence:seq];
    
    MPStrokeSequenceDimensionMapper *mapper
        = [[MPStrokeSequenceDimensionMapper alloc] initWithDataSet:[seqDB dataSetRepresentation]
                                          referenceStrokeSequences:_referenceStrokeSequences
                                                      resampleRate:_strokeResampleRate];
    
    id <MPTrainableDataSet> seqData = [mapper mappedDataSet];
    assert(seqData.datumCount == 1);
    
    NSArray *probs
        = [_classifier posteriorProbabilitiesForClassifyingDatum:[seqData datumAtIndex:0]];
    
    float maxValue;
    [probs indexOfMaxFloatValue:&maxValue];
    
    MPStrokeSequenceRecognition *recognition = [[MPStrokeSequenceRecognition alloc] init];
    recognition.score = maxValue;
    
    return recognition;
}

@end