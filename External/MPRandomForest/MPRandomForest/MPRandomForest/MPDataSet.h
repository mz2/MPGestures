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
    MPColumnTypeIntegral = 1,
    MPColumnTypeFloatingPoint
};

@protocol MPDatum;

/**
 * Represents objects that can be thought of as a set of rows & column.
 */
@protocol MPDataSet <NSObject>

@property (readonly, copy) NSArray *arrayOfDictionariesRepresentation;

@property (readonly) NSUInteger datumCount;

- (id<MPDatum>)datumAtIndex:(NSUInteger)i;

- (void)appendDatum:(id<MPDatum>)datum;

@end

typedef NSInteger MPDatumLabelIdentifier;

/**
 *  Represents objects that can be thought of as a single row in a data set.
 */
@protocol MPDatum <NSObject>
@property (weak, readonly) id<MPDataSet> dataSet;
@property (readonly) NSUInteger columnCount;

@property (readonly, copy) NSDictionary *dictionaryRepresentation;

@property (readonly) NSArray *columnTypes;

- (MPColumnType)typeForColumn:(NSUInteger)index;
- (id)valueForColumn:(NSUInteger)index;

- (id)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes;

@end