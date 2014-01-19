//
//  GestureView.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSTimeInterval MPGestureViewStrokesEndedInterval;

@class MPGestureView;
@class MPStrokeSequence, MPStroke, MPStrokeSequenceRecognition;

@protocol MPGestureViewDelegate <NSObject>

- (void)gestureView:(MPGestureView *)gestureView
     didStartStroke:(MPStroke *)stroke
   inStrokeSequence:(MPStrokeSequence *)strokeSequence;

- (void)gestureView:(MPGestureView *)gestureView
 didFinishDetection:(MPStrokeSequenceRecognition *)result
 withStrokeSequence:(MPStrokeSequence *)strokeSequence;

@end

@interface MPGestureView : NSView

@property (weak) IBOutlet id<MPGestureViewDelegate> delegate;

@property (readonly) BOOL isStroking;

@property NSArray *additionalStrokeSequences;

@property (readonly) NSUInteger selectedAdditionalStrokeSequenceIndex;

- (void)selectAdditionalStrokeSequenceAtIndex:(NSUInteger)index;

- (IBAction)clear:(id)sender;

@end
