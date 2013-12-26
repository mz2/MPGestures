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

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *gestureTextfield;
@property (weak) IBOutlet NSButton *submitGestureButton;

@property (weak) IBOutlet NSButton *nextGestureButton;
@property (weak) IBOutlet NSButton *previousGestureButton;
@property (weak) IBOutlet NSButton *deleteGestureButton;

@property (weak) IBOutlet NSComboBox *labelComboBox;

@property (strong) DollarStrokeSequenceDatabase *db;

@property (weak) IBOutlet MPGestureView *gestureView;

- (IBAction)addExample:(id)sender;

- (IBAction)nextStrokeSequence:(id)sender;
- (IBAction)previousStrokeSequence:(id)sender;
- (IBAction)deleteStrokeSequence:(id)sender;

@end