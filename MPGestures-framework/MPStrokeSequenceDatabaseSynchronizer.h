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

@interface MPStrokeSequenceDatabaseSynchronizer : NSObject

- (void)continuouslySynchronizeDatabase:(MPStrokeSequenceDatabase *)database;
- (void)stopContinuouslySynchronizingDatabase:(MPStrokeSequenceDatabase *)database;

- (BOOL)databaseIsContinuouslySynchronized:(MPStrokeSequenceDatabase *)database;

/**
 *  These databases with these identifiers are continuously synchronized with a remote server.
 */
@property (readonly) NSSet *continuouslySynchronizedDatabaseIdentifiers;

#pragma mark - Network IO

- (BOOL)addStrokeSequence:(MPStrokeSequence *)strokeSequence
             intoDatabase:(MPStrokeSequenceDatabase *)db
                    error:(NSError **)err;

- (BOOL)removeStrokeSequence:(MPStrokeSequence *)strokeSequence
                fromDatabase:(MPStrokeSequenceDatabase *)database
                       error:(NSError **)err;

@end
