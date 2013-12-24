//
//  MPAppDelegate.h
//  DollarP-OSX
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MPGestureView.h"

@class MPGestureView;

@interface MPAppDelegate : NSObject <NSApplicationDelegate, MPGestureViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *gestureLabel;

@property (weak) IBOutlet MPGestureView *gestureView;

@end