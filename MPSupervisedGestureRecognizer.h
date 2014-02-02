//
//  MPSupervisedGestureRecognizer.h
//  MPGestures
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPStrokeSequenceRecognizer.h"

@class MPStrokeSequenceDatabase;
@protocol MPDataSet;

/** Abstract base class for supervised gesture recognizers. */
@interface MPSupervisedGestureRecognizer : NSObject <MPStrokeSequenceRecognizer>

/** An ordered collection of label values. */
@property (readonly) NSArray *labelValues;

/** 
 *  Tests recognizing the labelled stroke sequences: outputs the recognitions and optionally a confusion matrix describing the misclassifications.
 *
 *  @param strokeSequences The input stroke sequences, with labels drawn from the same set as the training data for the recognizer.
 *  @param confusionMatrix An optional pointer to a confusion matrix data table pointer that describes the misclassifications.
 *  @param precision An optional floating point value pointer to mark the overall classification precision.
 *  @return An array of MPStrokeSequenceRecognition objects.
 */
- (NSArray *)evaluateRecognizerWithStrokeSequences:(NSArray *)strokeSequences
                               confusionMatrix:(id<MPDataSet> *)confusionMatrix
                                     precision:(float *)precision;

@end

@interface MPRandomForestGestureRecognizer : MPSupervisedGestureRecognizer
- (instancetype)initWithTrainingDatabase:(MPStrokeSequenceDatabase *)trainingDatabase
               referenceSequenceDatabase:(MPStrokeSequenceDatabase *)referenceDatabase;
@end