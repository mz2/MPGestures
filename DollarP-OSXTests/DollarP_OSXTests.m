//
//  DollarP_OSXTests.m
//  DollarP-OSXTests
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DollarStrokeSequenceDatabase.h"
#import "DollarStrokeSequence.h"
#import "DollarStroke.h"
#import "DollarPoint.h"
#import "DollarP.h"

@interface DollarP_OSXTests : XCTestCase

@end

@implementation DollarP_OSXTests

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
    DollarStrokeSequenceDatabase *db = [[DollarStrokeSequenceDatabase alloc] initWithDictionary:@{}];
    
    DollarStrokeSequence *seq = [[DollarStrokeSequence alloc] initWithDictionary:@{@"name":@"Foobar"}];
    DollarStroke *stroke1 = [[DollarStroke alloc] initWithDictionary:@{}];
    DollarStroke *stroke2 = [[DollarStroke alloc] initWithDictionary:@{}];
    
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
    
    DollarStrokeSequenceDatabase *deserialisedDB
        = [[DollarStrokeSequenceDatabase alloc] initWithContentsOfURL:url error:&err];
    
    NSArray *deserialisedSequences = deserialisedDB[@"Foobar"];
    
    XCTAssertTrue([deserialisedSequences isEqual:@[seq]], @"The deserialised stroke sequence is equal");
    
    XCTAssertTrue([db isEqual:deserialisedDB], @"The original and the deserialised database are equal.");
    
}

@end
