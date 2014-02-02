//
//  MPStrokeSequenceDatabase.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MPRandomForest/MPDataSet.h>

@class MPStrokeSequence;

/** A protocol used to label the kind of dataset returned by MPStrokeSequenceDatabase -dataSetRepresentation. */
@protocol MPStrokeSequenceDataSet <MPTrainableDataSet>
@end

/**
 *  Category name denoting a label for a stroke sequence (label meaning e.g. "triangle", "letter A").
 */
extern NSString * const MPCategoryNameStrokeSequenceLabel;

/** Column name in a dataset for a column containing stroke sequence labels (means the same as the corresponding category name MPCategoryNameStrokeSequenceLabel, but there can be multiple columns of the category, whereas just one column name per dataset). */
extern NSString * const MPColumnNameStrokeSequenceLabel;

/** Column name in a dataset for a column containing stroke sequence objects. */
extern NSString * const MPColumnNameStrokeSequenceObject;

extern NSString * const MPStrokeSequenceDatabaseErrorDomain;

/** A notification with this name is fired after a named stroke sequence has been added. 
  * The object of the notification is the database, and a userInfo dictionary with 'name' key is included with the stroke sequence's name, and 'strokeSequence' for the sequence object that was added.*/
extern NSString * const MPStrokeSequenceDatabaseDidAddSequenceNotification;

/** Fired after a named stroke sequence has been removed.
  * The object of the notification is the database, and a userInfo dictionary with 'name' key is included with the stroke sequence's name, and 'strokeSequence' for the sequence object that was removed. */
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
 *  A database that's been marked immutable is one whose stroke sequences or identifier shuold not be modified.
 */
@property (readonly, getter = isImmutable) BOOL immutable;

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

/** A JSON and plist encodable dictionary representation. */
@property (readonly, copy) NSDictionary *dictionaryRepresentation;

/**
 * A data set representation of the sequence database's stroke sequences.
 *
 * Includes two columns:
 *
 * 0. the stroke sequence as a custom object type.
 * 1. the sequence name label (a categorical field) */
@property (readonly, copy) id<MPStrokeSequenceDataSet> dataSetRepresentation;

/**
 *  Initialise a stroke sequence database with an identifier and a set of stroke sequences mapped to their names.
 *
 *  @param identifier        An identifier for the database.
 *  @param strokeSequenceMap A dictionary keyed on stroke sequence names, with an array of stroke sequences or stroke sequence dictionary representations as values.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                 strokeSequenceMap:(NSDictionary *)strokeSequenceMap;

/**
 *  Initialise an empty stroke sequence database with an identifier.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 *  Initialise a stroke sequence database with a single stroke sequence.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                    strokeSequence:(MPStrokeSequence *)strokeSequence;

/**
 *  Initialise a stroke sequence from its JSON / plist encodable dictionary representation.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)err;

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)err;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
