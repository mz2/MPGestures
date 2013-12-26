#import <Foundation/Foundation.h>
#import "MPPointCloudRecognition.h"
#import "MPPoint.h"

@interface MPDollarPointCloudRecognizer : NSObject;

@property (nonatomic, strong) NSMutableArray *pointClouds;

@property (readwrite) NSUInteger resampleCount;

+ (NSArray *)resample:(NSArray *)points numPoints:(NSUInteger)numPoints;
+ (NSArray *)scale:(NSArray *)points;
+ (NSArray *)translate:(NSArray *)points to:(MPPoint *)point;

- (MPPointCloudRecognition *)recognize:(NSArray *)points;
- (void)addGesture:(NSString *)name points:(NSArray *)points;

@end