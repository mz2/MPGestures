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
@class DollarStrokeSequence, DollarStroke, DollarResult;

@protocol MPGestureViewDelegate <NSObject>

- (void)gestureView:(MPGestureView *)gestureView
     didStartStroke:(DollarStroke *)stroke
   inStrokeSequence:(DollarStrokeSequence *)strokeSequence;

- (void)gestureView:(MPGestureView *)gestureView
 didFinishDetection:(DollarResult *)result
 withStrokeSequence:(DollarStrokeSequence *)strokeSequence;

@end

@interface MPGestureView : NSView

@property (weak) IBOutlet id<MPGestureViewDelegate> delegate;

@end
