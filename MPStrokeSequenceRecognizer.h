//
//  MPStrokeSequenceRecognizer.h
//  MPGestures
//
//  Created by Matias Piipari on 19/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPStrokeSequenceRecognition, MPStrokeSequence;

@protocol MPStrokeSequenceRecognizer <NSObject>

/**
 * Adds a stroke sequence to the recognizer's set of recognizable targets.
 * A recognizer can mangle the sequence's name to make it unique.
 */
- (void)addStrokeSequence:(MPStrokeSequence *)sequence;

/**
 *  Recognizes a stroke sequence.
 */
- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq;

@end
