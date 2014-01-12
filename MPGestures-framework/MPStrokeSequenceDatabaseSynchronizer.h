//
//  MPStrokeSequenceDatabaseSynchronizer.h
//  MPGestures
//
//  Created by Matias Piipari on 06/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPStrokeSequence, MPStrokeSequenceDatabase;

extern NSString * const MPStrokeSequenceDatabaseSynchronizerErrorDomain;

/**
  * Notifications with this name and an NSError object as the notification's object are posted
  * whenever continous synchronization hits issues.
  */
extern NSString * const MPStrokeSequenceDatabaseSynchronizerErrorNotification;

/**
  * Posted by the synchronizer whenever it has successfully finished synchronising the state of an object (add / remove).
  * The notification's object is the object that was synchronized, the database it belongs to is passed with the key "database" in user info, and an operation type (NSNumber with values from MPSynchronizerOperationType) that was conducted is passed with the key 'operationType'.
  */
extern NSString * const MPStrokeSequenceDatabaseObjectSynchronizedNotification;


typedef NS_ENUM(NSInteger, MPStrokeSequenceDatabaseSynchronizerErrorCode)
{
    MPStrokeSequenceDatabaseSynchronizerErrorCodeUnknown = 0,
    MPStrokeSequenceDatabaseSynchronizerErrorCodeInvalidResponse = 1,
    MPStrokeSequenceDatabaseSynchronizerErrorCodeServerReturnedError = 2
};

/**
 *  The type of an operation that the synchronizer completes for an object.
 */
typedef NS_ENUM(NSInteger, MPSynchronizerOperationType)
{
    MPSynchronizerOperationTypeUnknown = 0,
    MPSynchronizerOperationTypeList = 1,
    MPSynchronizerOperationTypeAdd = 2,
    MPSynchronizerOperationTypeRemove = 3
};

/**
 *  A service which listens to stroke sequence add / remove notifications posted by the sequence databases, and synchronises those changes with a remote service.
 */
@interface MPStrokeSequenceDatabaseSynchronizer : NSObject

/**
 *  The only way to access a MPStrokeSequenceDatabaseSynchronizer instance is the singleton instance. Do not attempt to initialise one yourself.
 */
+ (instancetype)sharedInstance;


- (void)continuouslySynchronizeDatabase:(MPStrokeSequenceDatabase *)database;
- (void)stopContinuouslySynchronizingDatabase:(MPStrokeSequenceDatabase *)database;

- (BOOL)databaseIsContinuouslySynchronized:(MPStrokeSequenceDatabase *)database;

/**
 *  These databases with these identifiers are continuously synchronized with a remote server.
 */
@property (readonly) NSSet *continuouslySynchronizedDatabaseIdentifiers;

#pragma mark - Network IO

/**
  * Adds the stroke sequence given as an argument to the database.
  * Stroke sequences are unique by their signature which is posted in the request body.
  *
  * If db is set to be continuously synchronised with the synchronizer,
  * there is no need to call this method for any of its stroke sequences.
  */
- (BOOL)addStrokeSequence:(MPStrokeSequence *)strokeSequence
             intoDatabase:(MPStrokeSequenceDatabase *)db
                    error:(NSError **)err;

/**
  * Removes the stroke sequence identified by the name and signature pair posted to the server.
  *
  * If db is set to be continuously synchronised with the synchronizer,
  * there is no need to call this method for any of its stroke sequences.
  */
- (BOOL)removeStrokeSequence:(MPStrokeSequence *)strokeSequence
                fromDatabase:(MPStrokeSequenceDatabase *)database
                       error:(NSError **)err;

/**
 *  All identifiers for stroke sequence databases stored on the server.
 */
- (NSArray *)databaseIdentifiersWithError:(NSError **)err;

/**
  * Returns a new stroke sequence database from the remote service,
  * containing all the stroke sequences with the matching identifier.
  */
- (MPStrokeSequenceDatabase *)databaseWithIdentifier:(NSString *)identifier
                                               error:(NSError **)err;

/**
 *  Returns a special sequence database representing the union of all gesture databases. 
 *  The identifier of the database is '<union>' and mutating it is not permitted (throws an exception).
 */
- (MPStrokeSequenceDatabase *)allGesturesDatabaseWithError:(NSError **)err;

/**
 *  Returns an array of StrokeSequence instances matching the signature and database identifier given as input.
 */
- (NSArray *)strokeSequencesWithSignature:(NSString *)signature
                 inDatabaseWithIdentifier:(NSString *)identifier
                                    error:(NSError **)err;

@end
