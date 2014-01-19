//
//  MPGesturesTestSuite.m
//  DollarP-OSXTests
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"
#import "MPStroke.h"
#import "MPPoint.h"
#import "MPDollarPointCloudRecognizer.h"

@interface MPGesturesTestSuite : XCTestCase

@end

@implementation MPGesturesTestSuite

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

// FIXME: move to a NSFileManager category.
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)testFoobar
{
    NSLog(@"Foo");
}

- (void)testStrokeDatabaseSerializationRoundtrip
{
    MPStrokeSequenceDatabase *db = [[MPStrokeSequenceDatabase alloc] initWithIdentifier:@"foobar"];
    
    MPStrokeSequence *seq = [[MPStrokeSequence alloc] initWithDictionary:@{@"name":@"Foobar"}];
    MPStroke *stroke1 = [[MPStroke alloc] initWithDictionary:@{}];
    MPStroke *stroke2 = [[MPStroke alloc] initWithDictionary:@{}];
    
    [stroke1 addPoint:CGPointMake(3,4) identifier:1];
    [stroke1 addPoint:CGPointMake(5,2) identifier:1];
    [stroke1 addPoint:CGPointMake(7,1) identifier:1];
    
    [stroke2 addPoint:CGPointMake(5,4) identifier:2];
    [stroke2 addPoint:CGPointMake(2,4) identifier:2];
    [stroke2 addPoint:CGPointMake(1,2) identifier:2];

    XCTAssertTrue(stroke1.pointsArray.count == 3, @"Three points in the first stroke.");
    XCTAssertTrue(stroke2.pointsArray.count == 3, @"Three points in the second stroke.");
    
    [seq addStroke:stroke1];
    [seq addStroke:stroke2];
    
    XCTAssertTrue(seq.strokesArray.count == 2, @"Two strokes were added.");
    
    [db addStrokeSequence:seq];
    
    NSError *err = nil;
    
    NSString *path = [self pathForTemporaryFileWithPrefix:@"test-strokes"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    XCTAssertTrue([db writeToURL:url error:&err],
                  @"Serializing the stroke sequence database succeeds.");
    
    MPStrokeSequenceDatabase *deserialisedDB
        = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:url error:&err];
    
    NSSet *deserialisedSequences = [deserialisedDB[@"Foobar"] copy];
    
    XCTAssertTrue([deserialisedSequences isEqualToSet:[NSSet setWithObject:seq]], @"The deserialised stroke sequence is equal");
    
    XCTAssertTrue([db isEqual:deserialisedDB], @"The original and the deserialised database are equal.");
    
    [db removeStrokeSequence:seq];
    
    XCTAssertTrue([db.strokeSequenceSet isEqualToSet:[NSSet setWithArray:@[]]],
                  @"No sequences after the only one was removed.");
    
}

@end
