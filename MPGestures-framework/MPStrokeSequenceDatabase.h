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

/**
  * Fired after significant externally derived changes have been made to the database.
  * Can be used by UI elements presenting contents of the stroke sequence to reload its state.
  */
extern NSString * const MPStrokeSequenceDatabaseChangedExternallyNotification;

typedef NS_ENUM(NSInteger, MPStrokeSequenceDatabaseErrorCode)
{
    MPStrokeSequenceDatabaseErrorCodeUnknown = 0,
    MPStrokeSequenceDatabaseErrorCodeInvalidFileFormat = 1
};

/**
  * The stroke sequence database is a key-value store of stroke sequences keyed by their name.
  * It can be accessed using the keyed subscript notation.
  * 
  * NOTE! It is permissible to create multiple stroke sequence databases with the same identifier, these objects are not "centrally uniqued" in the framework.
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

/**
 *  Adds the given stroke sequence to the database, if a matching sequence was not already present. 
 * Notifies with a MPStrokeSequenceDatabaseDidAddSequenceNotification.
 */
- (void)addStrokeSequence:(MPStrokeSequence *)sequence;

/**
 *  Removes the given stroke sequence from the database, if present.
 * Notifies with a MPStrokeSequenceDatabaseDidRemoveSequenceNotification.
 */
- (void)removeStrokeSequence:(MPStrokeSequence *)sequence;

/**
 * Adds all the stroke sequences from the given database to this.
 * Existing stroke sequences are kept intact.
 *
 * @param database The database from which to draw the stroke sequences from.
 * Must be non-nil, and not self.
 */
- (void)addStrokeSequencesFromDatabase:(MPStrokeSequenceDatabase *)database;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)err;

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
