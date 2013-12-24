//
//  MPAppDelegate.m
//  DollarP-OSX
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPGestureView.h"
#import "DollarResult.h"

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.window makeFirstResponder:self.gestureView];
    self.gestureLabel.stringValue = @"";
}

- (void)gestureView:(MPGestureView *)gestureView didDetectGesture:(DollarResult *)result
{
    self.gestureLabel.stringValue = result.name;
}

@end
