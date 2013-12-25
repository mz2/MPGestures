//
//  MPTrainableDataSet.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPDatum;

@protocol MPDataSet <NSObject>
- (NSArray *)arrayOfDictionariesRepresentation;
@property (readonly) NSUInteger datumCount;

- (id<MPDatum>)datumAtIndex:(NSUInteger)i;

@end

typedef NSInteger MPDatumLabelIdentifier;

@protocol MPDatum <NSObject>
@property (weak, readonly) id<MPDataSet> dataSet;
@end