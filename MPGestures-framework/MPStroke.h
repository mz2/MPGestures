//
//  Stroke.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
@compatibility_alias UIColor NSColor;
#endif

@class MPPoint;

@interface MPStroke : NSObject

@property (nonatomic, copy) NSArray *pointsArray;
@property (nonatomic, strong) UIColor *color;

- (void)addPoint:(CGPoint)p identifier:(NSUInteger)i;

@property (readonly) MPPoint *lastPoint;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/** Initialise a stroke with an array of MPPoint objects. */
- (instancetype)initWithPoints:(NSArray *)points;

+ (NSArray *)strokesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end
