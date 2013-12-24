//
//  MPAppDelegate.m
//  DollarP-OSX
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPGestureView.h"

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.window makeFirstResponder:self.gestureView];
}

@end
