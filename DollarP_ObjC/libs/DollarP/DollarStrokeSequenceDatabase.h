//
//  DollarStrokeSequenceDatabase.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DollarStrokeSequence;

extern NSString * const DollarStrokeSequenceDatabaseErrorDomain;

typedef NS_ENUM(NSInteger, DollarStrokeSequenceDatabaseErrorCode)
{
    DollarStrokeSequenceDatabaseErrorCodeUnknown = 0,
    DollarStrokeSequenceDatabaseErrorCodeInvalidFileFormat = 1
    
};

/**
 * The dollar stroke sequence database is a key-value store of stroke sequences keyed by their name.
 * It can be accessed using the keyed subscript notation.
 */
@interface DollarStrokeSequenceDatabase : NSObject

@property (readonly) NSSet *strokeSequenceNameSet;

- (void)addStrokeSequence:(DollarStrokeSequence *)sequence;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)err;

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
