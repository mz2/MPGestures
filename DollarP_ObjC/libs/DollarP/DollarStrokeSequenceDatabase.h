//
//  DollarStrokeSequenceDatabase.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DollarStrokeSequence;

@interface DollarStrokeSequenceDatabase : NSObject

- (void)addStrokeSequence:(DollarStrokeSequence *)sequence;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
