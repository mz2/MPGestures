//
//  MPGesturesIntegrationTests.m
//  MPGestures
//
//  Created by Matias Piipari on 11/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"
#import "MPStroke.h"
#import "MPPoint.h"
#import "MPDollarPointCloudRecognizer.h"

#import "MPStrokeSequenceDatabaseSynchronizer.h"

@interface MPGesturesIntegrationTests : XCTestCase
@property (readwrite) MPStrokeSequenceDatabase *db;
@property (readwrite) MPStrokeSequence *seq;
@end

@implementation MPGesturesIntegrationTests

- (void)setUp
{
    [super setUp];
    
    self.db = [[MPStrokeSequenceDatabase alloc] initWithIdentifier:@"foobar"];
    
    self.seq = [[MPStrokeSequence alloc] initWithDictionary:@{@"name":@"Foobar"}];
    MPStroke *stroke1 = [[MPStroke alloc] initWithDictionary:@{}];
    MPStroke *stroke2 = [[MPStroke alloc] initWithDictionary:@{}];
    
    [stroke1 addPoint:CGPointMake(3,4) identifier:1];
    [stroke1 addPoint:CGPointMake(5,2) identifier:1];
    [stroke1 addPoint:CGPointMake(7,1) identifier:1];
    
    [stroke2 addPoint:CGPointMake(5,4) identifier:2];
    [stroke2 addPoint:CGPointMake(2,4) identifier:2];
    [stroke2 addPoint:CGPointMake(1,2) identifier:2];
    
    [self.seq addStroke:stroke1];
    [self.seq addStroke:stroke2];
    
}

- (void)tearDown
{
    [super tearDown];
    
    MPStrokeSequenceDatabaseSynchronizer *service = [MPStrokeSequenceDatabaseSynchronizer sharedInstance];
    
    NSError *err = nil;

    NSArray *databaseIdentifiers = [service databaseIdentifiersWithError:&err];
    XCTAssertNotNil(databaseIdentifiers, @"Database identifiers were found.");
    XCTAssertTrue([[NSSet setWithArray:databaseIdentifiers] isEqual:
                   [NSSet setWithArray:@[@"foobar"]]],
                   @"Database identifier set matches expectation before deletion");
    
    for (NSString *identifier in databaseIdentifiers)
    {
        NSError *e = nil;
        MPStrokeSequenceDatabase *db = [service databaseWithIdentifier:identifier error:&e];
        
        XCTAssertNotNil(db, @"A database could be instantiated.");
        
        for (MPStrokeSequence *seq in [db strokeSequenceSet])
        {
            NSError *remerr = nil;
            XCTAssertTrue([service removeStrokeSequence:seq fromDatabase:db error:&remerr],
                          @"Removing stroke sequence succeeded.");
        }
    }

}

- (void)testAddingToSynchronizerService
{
    MPStrokeSequenceDatabaseSynchronizer *service = [MPStrokeSequenceDatabaseSynchronizer sharedInstance];
    
    NSError *err = nil;
    XCTAssertTrue([service addStrokeSequence:self.seq intoDatabase:self.db error:&err], @"Adding sequence succeeded.");
    [self.db addStrokeSequence:self.seq];
}

- (void)testListingSynchronizerServiceDatabaseContents
{
    MPStrokeSequenceDatabaseSynchronizer *service = [MPStrokeSequenceDatabaseSynchronizer sharedInstance];
    
    NSError *err = nil;
    MPStrokeSequenceDatabase *db = [service databaseWithIdentifier:@"mpgestures" error:&err];
    
    XCTAssertNotNil(db, @"A database was successfully created.");
}

@end
