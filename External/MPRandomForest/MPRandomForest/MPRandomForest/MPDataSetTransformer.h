//
//  MPDataSetTransformer.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPDataSet.h"

@protocol MPDataSetTransformer <NSObject>

@property (readonly) id<MPDataSet> dataSet;

@property (readonly) NSUInteger classCount;
@property (readonly) NSUInteger featureCount;

- (instancetype)initWithDataSet:(id<MPDataSet>)dataSet;

- (double *)newTransform:(id<MPDatum>)datum;

- (MPDatumLabelIdentifier)labelIdentifierForDatum:(id<MPDatum>)datum;
- (NSString *)labelForDatum:(id<MPDatum>)datum;


@end
