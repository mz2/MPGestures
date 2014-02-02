#import <Foundation/Foundation.h>
#import "MPStrokeSequenceRecognition.h"
#import "MPPoint.h"

#import "MPStrokeSequenceRecognizer.h"

@class MPStrokeSequence, MPPointCloud;

@interface MPDollarPointCloudRecognizer : NSObject <MPStrokeSequenceRecognizer>

@property (nonatomic, strong) NSMutableArray *pointClouds;

/**
 *  All point clouds added to the recognizer get resampled at this rate.
 */
@property (readwrite) NSUInteger resampleRate;

+ (NSArray *)resample:(NSArray *)points numPoints:(NSUInteger)numPoints;

+ (NSArray *)normalizeScale:(NSArray *)points;
+ (NSArray *)scalePoints:(NSArray *)points byRatio:(float)ratio;

+ (NSArray *)translate:(NSArray *)points to:(MPPoint *)point;

- (MPStrokeSequenceRecognition *)recognize:(NSArray *)points;
- (void)addGesture:(NSString *)name points:(NSArray *)points;

/** Adds a point cloud representation of a stroke sequence at the recognizer's resampling rate. */
- (void)addStrokeSequence:(MPStrokeSequence *)sequence;

/** Recognizes a stroke sequence given its point cloud representation. */
- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq;

/** Score a point cloud with a template point cloud at the specified resampling rate. */
+ (float)scoreForGreedyCloudMatchOfPointCloud:(MPPointCloud *)pointCloud
                                 withTemplate:(MPPointCloud *)templatePointCloud
                               atResamplerate:(NSUInteger)resampleRate;

+ (NSArray *)processPoints:(NSArray *)points atResamplingRate:(NSUInteger)resampleRate;

@end