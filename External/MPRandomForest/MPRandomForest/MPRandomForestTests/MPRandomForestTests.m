//
//  MPRandomForestTests.m
//  MPRandomForestTests
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPDataSet.h"
#import "MPDataTable.h"
#import "NSNumber+NumericalType.h"

@interface MPRandomForestTests : XCTestCase

@end

@implementation MPRandomForestTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testNumberExtension
{
    XCTAssertTrue([@(YES) isBOOL],
                  @"A boxed YES literal is detected as a BOOL.");
    XCTAssertTrue([@(NO) isBOOL],
                  @"A boxed NO literal is detected as a BOOL.");

    XCTAssertTrue(![@(YES) isIntegral],
                  @"A boxed YES literal is NOT detected as integral.");
    XCTAssertTrue(![@(NO) isIntegral],
                  @"A boxed NO literal is detected as integral.");

    XCTAssertTrue([@(1) isIntegral],
                  @"A boxed 1 literal is detected as integral.");
    XCTAssertTrue(![@(1.04) isBOOL],
                  @"A boxed 1.04 literal is NOT detected as BOOL.");
    XCTAssertTrue(![@(1.04) isIntegral],
                  @"A boxed 1.04 literal is NOT detected as integral.");
    XCTAssertTrue([@(1.04) isFloatingPoint],
                  @"A boxed 1.04 literal is detected as floating point.");
}

- (void)testDataTableCreation
{
    NSArray *columnTypes = @[@(MPColumnTypeCategorical), @(MPColumnTypeBinary)];
    MPDataTable *tbl = [[MPDataTable alloc] initWithColumnTypes:columnTypes];
    [tbl appendDatum:[[MPRow alloc] initWithValues:@[(@"foobar"), @(YES)]
                                       columnTypes:columnTypes]];
}

@end
