//
//  MPAppDelegate.h
//  DollarP-OSX
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MPGestureView.h"

#import "DollarStrokeSequenceDatabase.h"

@class MPGestureView;

@interface MPAppDelegate : NSObject <NSApplicationDelegate, MPGestureViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *gestureLabel;
@property (assign) IBOutlet NSTextField *gestureTextfield;

@property (strong) DollarStrokeSequenceDatabase *db;

@property (weak) IBOutlet MPGestureView *gestureView;

- (IBAction)addExample:(id)sender;

@end