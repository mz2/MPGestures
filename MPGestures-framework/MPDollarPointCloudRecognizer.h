#import <Foundation/Foundation.h>
#import "MPPointCloudRecognition.h"
#import "MPPoint.h"

@class MPStrokeSequence;

@interface MPDollarPointCloudRecognizer : NSObject;

@property (nonatomic, strong) NSMutableArray *pointClouds;

/**
 *  All point clouds added to the recognizer get resampled at this rate.
 */
@property (readwrite) NSUInteger resampleRate;

+ (NSArray *)resample:(NSArray *)points numPoints:(NSUInteger)numPoints;
+ (NSArray *)scale:(NSArray *)points;
+ (NSArray *)translate:(NSArray *)points to:(MPPoint *)point;

- (MPPointCloudRecognition *)recognize:(NSArray *)points;
- (void)addGesture:(NSString *)name points:(NSArray *)points;

/**
 *  Adds a point cloud representation of a stroke sequence at the recognizer's resampling rate.
 */
- (void)addStrokeSequence:(MPStrokeSequence *)sequence;

/**
 *  Recognizes a stroke sequence given its point cloud representation.
 */
- (MPPointCloudRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq;

@end