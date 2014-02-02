//
//  MPGestureViewController.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 26/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPGestureView.h"

#import "PARViewController.h"

@class MPStrokeSequenceDatabase;

@interface MPGestureViewController : PARViewController <MPGestureViewDelegate,
                                                        NSTextFieldDelegate,
                                                        NSComboBoxDelegate,
                                                        NSComboBoxDataSource>

@property (readonly, weak) MPGestureView *gestureView;

@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *gestureTextfield;
@property (weak) IBOutlet NSButton *submitGestureButton;

@property (weak) IBOutlet NSButton *nextGestureButton;
@property (weak) IBOutlet NSButton *previousGestureButton;
@property (weak) IBOutlet NSButton *deleteGestureButton;

@property (weak) IBOutlet NSComboBox *labelComboBox;

@property (strong) MPStrokeSequenceDatabase *db;

@property (strong) IBOutlet NSView *openPanelAccessoryView;

- (IBAction)addExample:(id)sender;

- (IBAction)nextStrokeSequence:(id)sender;
- (IBAction)previousStrokeSequence:(id)sender;
- (IBAction)deleteStrokeSequence:(id)sender;

@end
