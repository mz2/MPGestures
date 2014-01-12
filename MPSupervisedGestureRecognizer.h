//
//  MPSupervisedGestureRecognizer.h
//  MPGestures
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Abstract base class for supervised gesture recognizers.
 */
@interface MPSupervisedGestureRecognizer : NSObject

@end

@interface MPRandomForestGestureRecognizer : MPSupervisedGestureRecognizer

@end