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
 *  Recognizes a stroke sequence.
 */
- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq;


@end
