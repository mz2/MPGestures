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

@interface MPSupervisedGestureRecognizer ()
@property (readonly) MPDataTable *trainingData;
@end

@interface MPRandomForestGestureRecognizer ()
@property (readonly) MPALGLIBDecisionForestClassifier *classifier;
@end

@implementation MPSupervisedGestureRecognizer

- (id)init
{
    @throw [NSException exceptionWithName:@"MPAbstractClassException" reason:nil userInfo:nil];
    return nil;
}

- (instancetype)initRecognizer
{
    self = [super init];
    if (self) {
        
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

@implementation MPRandomForestGestureRecognizer

- (instancetype)initWithSequenceDatabase:(MPStrokeSequenceDatabase *)database
{
    self = [super initRecognizer];
    if (self) {
        
        id<MPTrainableDataSet> dataset = [database dataSetRepresentation];
        
        _classifier = [[MPALGLIBDecisionForestClassifier alloc]
                        initWithTransformer:[[MPIdentityTransformer alloc] initWithDataSet:dataset]
                       trainingData:dataset];
    }
    return self;
}

@end