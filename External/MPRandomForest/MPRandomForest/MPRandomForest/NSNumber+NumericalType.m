//
//  NSNumber+NumericalType.m
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Manuscripts.app Limited. All rights reserved.
//

#import "NSNumber+NumericalType.h"

@implementation NSNumber (NumericalType)

- (BOOL)isFloatingPoint
{
    return CFNumberIsFloatType((__bridge CFNumberRef)self);
}

- (BOOL)isBOOL
{
    BOOL isFP = [self isFloatingPoint];
    if (isFP) return NO;
    
    CFNumberType type = CFNumberGetType((__bridge CFNumberRef)self);
    return (type == kCFNumberCharType);
}

- (BOOL)isIntegral
{
    return ![self isFloatingPoint] && ![self isBOOL];
}

@end
