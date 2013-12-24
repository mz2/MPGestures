//
//  GestureView.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPGestureView : NSView
{
    NSMutableDictionary *currentTouches;
    NSMutableArray *completeStrokes;
}

- (void)clearAll;
@end
