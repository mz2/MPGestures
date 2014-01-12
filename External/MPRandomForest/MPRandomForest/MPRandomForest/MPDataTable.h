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
 *  Creates an empty dataset with the specified column types (all datum entries must have matching column types) and an expected capacity.
 *
 *  @param columnTypes An array of unsigned integers with values from the MPColumnType enum.
 *  @param capacity positive integer, or 0 if expected required capacity not known.
 */
- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
                      datumCapacity:(NSUInteger)capacity;

/**
 *  A shorthand for -initWithColumnTypes:columnTypes datumCapacity:0
 */
- (instancetype)initWithColumnTypes:(NSArray *)columnTypes;

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
  * Initialises a row with the given values and column types.
  * Both the 'values' and 'columnTypes' arguments are required.
  */
- (instancetype)initWithValues:(NSArray *)values
                   columnTypes:(NSArray *)columnTypes;

@end