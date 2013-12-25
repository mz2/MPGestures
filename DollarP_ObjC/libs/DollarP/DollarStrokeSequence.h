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

@property NSString *name;

@property (readonly) NSArray *strokesArray;

- (void)addStroke:(DollarStroke *)stroke;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithName:(NSString *)name strokes:(NSArray *)arrays;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)strokeSequencesWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end
