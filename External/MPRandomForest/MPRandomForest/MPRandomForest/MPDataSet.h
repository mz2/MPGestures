//
//  MPTrainableDataSet.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Represents the type of a column of data.
 */
typedef NS_ENUM(NSUInteger, MPColumnType) {
    MPColumnTypeUnknown = 0,
    MPColumnTypeCategorical = 1,
    MPColumnTypeIntegral = 2,
    MPColumnTypeFloatingPoint = 3,
    MPColumnTypeBinary = 4
};

@protocol MPDatum;

/**
 * Represents objects that can be thought of as a set of rows & column.
 */
@protocol MPDataSet <NSObject>

@property (readonly, copy) NSArray *arrayOfDictionariesRepresentation;

@property (readonly) NSUInteger datumCount;

/**
 *  The column types of all datum entries in a data set must match that of the data set.
 */
@property (readonly) NSArray *columnTypes;

- (id<MPDatum>)datumAtIndex:(NSUInteger)i;

- (void)appendDatum:(id<MPDatum>)datum;

@end

typedef NSInteger MPDatumLabelIdentifier;

/**
 *  Represents objects that can be thought of as a single row in a data set.
 */
@protocol MPDatum <NSObject>

/**
 *  Back pointer to the datum's data set. This should be set only once and only by the data set.
 */
@property (weak, readonly) id<MPDataSet> dataSet;
@property (readonly) NSUInteger columnCount;

@property (readonly, copy) NSDictionary *dictionaryRepresentation;

@property (readonly) NSArray *columnTypes;

- (MPColumnType)typeForColumn:(NSUInteger)index;
- (id)valueForColumn:(NSUInteger)index;

- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes;

@end