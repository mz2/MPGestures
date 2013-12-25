//
//  MPRandomForest.h
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPDataSetTransformer.h"

static const NSUInteger MPRandomForestDefaultTreeCount = 200;

@class MPDatum;

@interface MPDatumClassifier : NSObject
- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(MPDatum *)datum;

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                               data:(id<MPDataSet>)data;
@end

@interface MPRandomForestClassifier : MPDatumClassifier

@property (readonly) id<MPDataSetTransformer> transformer;

@property (readwrite) NSUInteger treeCount;

- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(MPDatum *)datum;

@end