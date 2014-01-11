//
//  MPStrokeSequenceDatabase.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPStrokeSequence;

extern NSString * const MPStrokeSequenceDatabaseErrorDomain;

/** A notification with this name is fired after a named stroke sequence has been added. 
  * The object of the notification is the database, and a userInfo dictionary with 'name' key is included with the stroke sequence's name.*/
extern NSString * const MPStrokeSequenceDatabaseDidAddSequenceNotification;

/** Fired after a named stroke sequence has been removed.
  * The object of the notification is the database, and a userInfo dictionary with 'name' key is included with the stroke sequence's name. */
extern NSString * const MPStrokeSequenceDatabaseDidRemoveSequenceNotification;

typedef NS_ENUM(NSInteger, MPStrokeSequenceDatabaseErrorCode)
{
    MPStrokeSequenceDatabaseErrorCodeUnknown = 0,
    MPStrokeSequenceDatabaseErrorCodeInvalidFileFormat = 1
    
};

/**
 * The dollar stroke sequence database is a key-value store of stroke sequences keyed by their name.
 * It can be accessed using the keyed subscript notation.
 */
@interface MPStrokeSequenceDatabase : NSObject

/**
 * A unique identifier for the stroke sequence database.
 * Only one database with this identifier is stored on a stroke sequence server.
 */
@property (readonly) NSString *identifier;

@property (readonly) NSSet *strokeSequenceNameSet;

@property (readonly) NSArray *sortedStrokeSequenceNames;

@property (readonly) NSSet *strokeSequenceSet;

- (void)addStrokeSequence:(MPStrokeSequence *)sequence;

- (void)removeStrokeSequence:(MPStrokeSequence *)sequence;

/**
 *  Replaces all the stroke sequences in this database with those from a database given as an input.
 *
 *  @param database The database from which to draw the stroke sequences from.
 */
- (void)replaceStrokeSequencesWithContentsOfDatabase:(MPStrokeSequenceDatabase *)database;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)err;

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
