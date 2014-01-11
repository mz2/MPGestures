//
//  MPDollarStrokeSequence.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPStroke, MPPointCloud;

@interface MPStrokeSequence : NSObject

@property (readonly) NSString *name;

@property (readonly) NSArray *strokesArray;

@property (readonly) NSUInteger strokeCount;

- (BOOL)containsStroke:(MPStroke *)stroke;

- (void)addStroke:(MPStroke *)stroke;

- (MPStroke *)lastStroke;

- (NSDictionary *)dictionaryRepresentation;

- (MPPointCloud *)pointCloudRepresentationWithResampleCount:(NSUInteger)resampledPointCount;

- (instancetype)initWithName:(NSString *)name strokes:(NSArray *)arrays;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithStrokeSequence:(MPStrokeSequence *)sequence;

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end
