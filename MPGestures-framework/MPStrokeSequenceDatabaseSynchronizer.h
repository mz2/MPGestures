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

typedef NS_ENUM(NSInteger, MPStrokeSequenceDatabaseSynchronizerErrorCode)
{
    MPStrokeSequenceDatabaseSynchronizerErrorCodeUnknown = 0,
    MPStrokeSequenceDatabaseSynchronizerErrorCodeInvalidResponse = 1,
    MPStrokeSequenceDatabaseSynchronizerErrorCodeServerReturnedError = 2
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
 */
- (BOOL)addStrokeSequence:(MPStrokeSequence *)strokeSequence
             intoDatabase:(MPStrokeSequenceDatabase *)db
                    error:(NSError **)err;

/**
 *  Removes the stroke sequence identified by the name and signature pair posted to the server.
 */
- (BOOL)removeStrokeSequence:(MPStrokeSequence *)strokeSequence
                fromDatabase:(MPStrokeSequenceDatabase *)database
                       error:(NSError **)err;

/**
 *  Constructs a new stroke sequence database 
 */
- (MPStrokeSequenceDatabase *)databaseWithIdentifier:(NSString *)identifier
                                               error:(NSError **)err;

@end
