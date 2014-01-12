//
//  NSNumber+NumericalType.h
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (NumericalType)

/**
 *  The number is a floating point type (as determined by CFNumberIsFloatType(self).
 */
@property (readonly) BOOL isFloatingPoint;

/**
 *  The number is a non-floating point, char type number.
 */
@property (readonly) BOOL isBOOL;

/**
 *  The number is a non-floating point, non-BOOL type number (e.g. shorts are taken as integral).
 */
@property (readonly) BOOL isIntegral;

@end
