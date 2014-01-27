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

/**
 *  Abstract base class for supervised gesture recognizers.
 */
@interface MPSupervisedGestureRecognizer : NSObject <MPStrokeSequenceRecognizer>
@end

@interface MPRandomForestGestureRecognizer : MPSupervisedGestureRecognizer
- (instancetype)initWithTrainingDatabase:(MPStrokeSequenceDatabase *)trainingDatabase
               referenceSequenceDatabase:(MPStrokeSequenceDatabase *)referenceDatabase;
@end