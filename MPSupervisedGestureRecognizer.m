//
//  MPSupervisedGestureRecognizer.m
//  MPGestures
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import "MPSupervisedGestureRecognizer.h"

#import <MPRandomForest/MPDatumClassifier.h>

@implementation MPSupervisedGestureRecognizer

- (id)init
{
    @throw [NSException exceptionWithName:@"MPAbstractClassException" reason:nil userInfo:nil];
    return nil;
}

- (instancetype)initRecognizer
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

@implementation MPRandomForestGestureRecognizer

- (instancetype)init
{
    self = [super initRecognizer];
    if (self) {
        
    }
    return self;
}

@end