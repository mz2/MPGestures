//
//  GestureView.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MPGestureView, DollarResult;

@protocol MPGestureViewDelegate <NSObject>

- (void)gestureView:(MPGestureView *)gestureView didDetectGesture:(DollarResult *)result;

@end

@interface MPGestureView : NSView
- (void)clearAll;
@end
