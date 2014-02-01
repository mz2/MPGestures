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

- (NSArray *)labelValues {
    return [[[_trainingDatabase strokeSequenceNameSet] allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)sequence {
    @throw [NSException exceptionWithName:@"MPAbstractMethodException" reason:nil userInfo:nil];
}

- (NSArray *)testRecognizerWithStrokeSequences:(NSArray *)strokeSequences
                               confusionMatrix:(id<MPDataSet> *)confusionMatrix
                                     precision:(float *)precision {
    NSMutableArray *recognitions = [NSMutableArray arrayWithCapacity:strokeSequences.count];
    NSMutableArray *colTypes = [NSMutableArray arrayWithCapacity:self.labelValues.count];
    NSMutableArray *confusions = [NSMutableArray arrayWithCapacity:self.labelValues.count];
    
    NSUInteger correct = 0;
    NSUInteger incorrect = 0;
    
    for (NSUInteger i = 0, cnt = self.labelValues.count; i < cnt; i++) {
        [colTypes addObject:@(MPColumnTypeIntegral)];
        [confusions addObject:@(0)];
    }
    
    id<MPDataSet> confMatrix = [[MPDataTable alloc] initWithColumnTypes:[colTypes copy]
                                                            columnNames:self.labelValues
                                                       labelColumnIndex:NSNotFound
                                                          datumCapacity:strokeSequences.count];
    
    for (NSUInteger i = 0, cnt = self.labelValues.count; i < cnt; i++) {
        id<MPDatum> datum = [[MPDataTableRow alloc] initWithValues:confusions.copy columnTypes:confMatrix.columnTypes];
        [confMatrix appendDatum:datum];
    }
    
    for (MPStrokeSequence *seq in strokeSequences) {
        MPStrokeSequenceRecognition *recognition = [self recognizeStrokeSequence:seq];
        recognition.correctName = seq.name;
        
        [recognitions addObject:recognition];
        
        // update confusion matrix for misclassifications.
        if (![recognition.name isEqualToString:seq.name]) {
            incorrect++;
            
            NSUInteger datumIndex = [self.labelValues indexOfObject:seq.name];
            NSUInteger columnIndex = [self.labelValues indexOfObject:recognition.name];

            id<MPDatum> datum = [confMatrix datumAtIndex:datumIndex];
            NSUInteger val = [[datum valueForColumn:columnIndex] unsignedIntegerValue];
            [datum setValue:@(val + 1) forColumn:columnIndex];
        } else {
            correct++;
        }
    }
    
    if (confusionMatrix)
        *confusionMatrix = confMatrix;
    
    if (precision)
        *precision = (float)correct / (float)(correct + incorrect);
    
    return recognitions;
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
    
    float maxValue = INFINITY;
    NSUInteger index = [probs indexOfMaxFloatValue:&maxValue];
    
    NSString *label = [_trainingDataSet labelValues][index];
    MPStrokeSequenceRecognition *recognition = [[MPStrokeSequenceRecognition alloc] initWithName:label score:maxValue];
    recognition.scores = probs;
    
    return recognition;
}

@end