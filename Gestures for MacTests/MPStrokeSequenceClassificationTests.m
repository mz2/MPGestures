//
//  MPStrokeSequenceClassificationTests.m
//  MPGestures
//
//  Created by Matias Piipari on 19/01/2014.
//  Copyright (c) 2014 de.ur. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPStrokeSequenceDatabase.h"
#import "MPStrokeSequence.h"
#import "MPStroke.h"
#import "MPPoint.h"
#import "MPDollarPointCloudRecognizer.h"
#import "MPStrokeSequenceRecognition.h"

#import "MPSupervisedGestureRecognizer.h"

@interface MPStrokeSequenceClassificationTests : XCTestCase
@end

@implementation MPStrokeSequenceClassificationTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testUnsupervisedPointCloudRecognition
{
    NSError *dbErr = nil;
    NSURL *trainingDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"square-triangle-circle-train"
                                                         withExtension:@"strokedb"
                                                          subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *db = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:trainingDatabaseURL error:&dbErr];
    
    XCTAssertTrue(db != nil, @"A database was successfully loaded.");
    
    BOOL sequenceSetNamesMatch = [[db strokeSequenceNameSet] isEqualToSet:
                                  [NSSet setWithArray:@[@"circle", @"triangle", @"square"]]];
    XCTAssertTrue(sequenceSetNamesMatch, @"The set of stroke sequence labels matches expectation.");
    
    MPDollarPointCloudRecognizer *recognizer = [[MPDollarPointCloudRecognizer alloc] init];
    recognizer.resampleRate = 32;
    
    for (MPStrokeSequence *seq in db.strokeSequenceSet) {
        [recognizer addStrokeSequence:seq];
    }
    
    // should always recognise self and therefore have self's name as a prefix:
    // recognizer's point clouds have names corresponding to label-signature combination.
    for (MPStrokeSequence *seq in db.strokeSequenceSet) {
        MPStrokeSequenceRecognition *recognition = [recognizer recognizeStrokeSequence:seq];
        
        XCTAssertTrue([recognition.name hasPrefix:seq.name], @"%@ != %@",
                      recognition.name, seq.name);
    }
}

- (void)testSupervisedCircleTriangleSquareDetection {
    NSError *dbErr = nil;
    NSURL *trainingDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"square-triangle-circle-train"
                                                                                                     withExtension:@"strokedb"
                                                                                                      subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *traindb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:trainingDatabaseURL error:&dbErr];
    XCTAssertTrue(traindb != nil, @"A training database was successfully loaded.");
    
    NSURL *referenceDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"square-triangle-circle-ref"
                                                                                                     withExtension:@"strokedb"
                                                                                                      subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *rdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:referenceDatabaseURL error:&dbErr];
    MPRandomForestGestureRecognizer *recognizer
        = [[MPRandomForestGestureRecognizer alloc] initWithTrainingDatabase:traindb referenceSequenceDatabase:rdb maxReferenceSequencesPerLabel:16];
    XCTAssertTrue(recognizer != nil, @"A recognizer could be created.");
    
    NSURL *testDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"square-triangle-circle-test" withExtension:@"strokedb" subdirectory:@"Fixtures"];
    NSError *testDbErr = nil;
    MPStrokeSequenceDatabase *testdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:testDatabaseURL error:&testDbErr];
    
    NSArray *testStrokes = [[testdb.strokeSequenceSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    id<MPDataSet> confMatrix = nil;
    float precision = 0;
    
    NSArray *recognitions = [recognizer evaluateRecognizerWithStrokeSequences:testStrokes confusionMatrix:&confMatrix precision:&precision];
    XCTAssertTrue(recognitions.count == testStrokes.count, @"The expected number of recognitions were recovered.");
    NSLog(@"\nPrecision:%f\nConfusion matrix:\n%@",precision, confMatrix);
    XCTAssertTrue(precision > 0.85, @"Precision with this test case should be at least 90%%");
}

- (void)testEmojiDetection {
    NSError *dbErr = nil;
    NSURL *trainingDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"emoji-train"
                                                                                                     withExtension:@"strokedb"
                                                                                                      subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *traindb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:trainingDatabaseURL error:&dbErr];
    XCTAssertTrue(traindb != nil, @"A training database was successfully loaded.");
    
    NSURL *referenceDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"emoji-train"
                                                                                                      withExtension:@"strokedb"
                                                                                                       subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *rdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:referenceDatabaseURL error:&dbErr];
    MPRandomForestGestureRecognizer *recognizer
    = [[MPRandomForestGestureRecognizer alloc] initWithTrainingDatabase:traindb referenceSequenceDatabase:rdb maxReferenceSequencesPerLabel:16];
    XCTAssertTrue(recognizer != nil, @"A recognizer could be created.");
    
    NSURL *testDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"emoji-test"
                                                                                                 withExtension:@"strokedb"
                                                                                                  subdirectory:@"Fixtures"];
    NSError *testDbErr = nil;
    MPStrokeSequenceDatabase *testdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:testDatabaseURL error:&testDbErr];
    
    NSArray *testStrokes = [[testdb.strokeSequenceSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    id<MPDataSet> confMatrix = nil;
    float precision = 0;
    
    NSArray *recognitions = [recognizer evaluateRecognizerWithStrokeSequences:testStrokes confusionMatrix:&confMatrix precision:&precision];
    XCTAssertTrue(recognitions.count == testStrokes.count, @"The expected number of recognitions were recovered.");
    NSLog(@"\nPrecision:%f\nConfusion matrix:\n%@",precision, confMatrix);
    XCTAssertTrue(precision >= 0.95, @"Precision with this test case should be at least 90%%");

}

- (void)testSupervisedGreekAlphabetRecognition {
    NSError *dbErr = nil;
    NSURL *trainingDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"greek-alphabet"
                                                                                                     withExtension:@"strokedb"
                                                                                                      subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *traindb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:trainingDatabaseURL error:&dbErr];
    XCTAssertTrue(traindb != nil, @"A training database was successfully loaded.");
    
    NSURL *referenceDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"greek-alphabet" withExtension:@"strokedb" subdirectory:@"Fixtures"];
    MPStrokeSequenceDatabase *rdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:referenceDatabaseURL error:&dbErr];
    MPRandomForestGestureRecognizer *recognizer
        = [[MPRandomForestGestureRecognizer alloc] initWithTrainingDatabase:traindb referenceSequenceDatabase:rdb maxReferenceSequencesPerLabel:8];
        XCTAssertTrue(recognizer != nil, @"A recognizer could be created.");
    
    NSURL *testDatabaseURL = [[NSBundle bundleWithIdentifier:@"com.piipari.gestures.tests"] URLForResource:@"greek-alphabet-ref-2" withExtension:@"strokedb" subdirectory:@"Fixtures"];
    NSError *testDbErr = nil;
    MPStrokeSequenceDatabase *testdb = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:testDatabaseURL error:&testDbErr];
    
    NSArray *testStrokes = [[testdb.strokeSequenceSet allObjects] sortedArrayUsingSelector:@selector(compare:)];

    id<MPDataSet> confMatrix = nil;
    float precision = 0;

    NSArray *recognitions = [recognizer evaluateRecognizerWithStrokeSequences:testStrokes confusionMatrix:&confMatrix precision:&precision];
    XCTAssertTrue(recognitions.count == testStrokes.count, @"The expected number of recognitions were recovered.");
    NSLog(@"\nPrecision:%f\nConfusion matrix:\n%@",precision, confMatrix);
    XCTAssertTrue(precision > 0.75, @"Precision with this test case should be at least 75%%");
}

@end