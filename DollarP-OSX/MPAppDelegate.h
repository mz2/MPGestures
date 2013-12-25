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

@interface MPAppDelegate : NSObject <NSApplicationDelegate,
                                     MPGestureViewDelegate,
                                     NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *gestureLabel;
@property (assign) IBOutlet NSTextField *gestureTextfield;
@property (assign) IBOutlet NSButton *submitGestureButton;

@property (assign) IBOutlet NSButton *nextGestureButton;
@property (assign) IBOutlet NSButton *previousGestureButton;
@property (assign) IBOutlet NSButton *deleteGestureButton;

@property (strong) DollarStrokeSequenceDatabase *db;

@property (weak) IBOutlet MPGestureView *gestureView;

- (IBAction)addExample:(id)sender;

- (IBAction)nextStrokeSequence:(id)sender;
- (IBAction)previousStrokeSequence:(id)sender;
- (IBAction)deleteStrokeSequence:(id)sender;

@end