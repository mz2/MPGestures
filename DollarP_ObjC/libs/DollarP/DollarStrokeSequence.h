//
//  DollarStrokeSequence.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DollarStroke;

@interface DollarStrokeSequence : NSObject

@property (readonly) NSString *name;

@property (readonly) NSArray *strokesArray;

@property (readonly) NSUInteger strokeCount;

- (void)addStroke:(DollarStroke *)stroke;

- (DollarStroke *)lastStroke;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithName:(NSString *)name strokes:(NSArray *)arrays;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithStrokeSequence:(DollarStrokeSequence *)sequence;

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end
