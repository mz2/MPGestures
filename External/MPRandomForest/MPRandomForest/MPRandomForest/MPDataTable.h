//
//  MPNumericalDataSet.h
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDataSet.h"

/**
 *  A concrete implementation of MPDataSet.
 */
@interface MPDataTable : NSObject <MPDataSet>

/**
 *  Creates an empty dataset with the specified capacity.
 *
 *  @param capacity positive integer, or 0 if required capacity not known.
 */
- (instancetype)initWithCapacity:(NSUInteger)capacity;

/**
 *  An array of id<MPDatum> instances.
 */
@property (readonly, copy) NSArray *datumArray;

/**
  * Appends a datum into the dataset.
  *
  * The first datum has a special meaning: it is used to check that subsequent rows have similar array of column types.
  */
- (void)appendDatum:(id<MPDatum>)datum;

@end

@interface MPRow : NSObject <MPDatum>

/**
 *  Initialises a row with the given values and column types. The number of values and column types must match.
 */
- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes;

@end