#import <Foundation/Foundation.h>
#import "DollarResult.h"
#import "DollarPoint.h"

@interface DollarP : NSObject;

@property (nonatomic, strong) NSMutableArray *pointClouds;

@property (readwrite) NSUInteger resampleCount;

+ (NSArray *)resample:(NSArray *)points numPoints:(NSUInteger)numPoints;
+ (NSArray *)scale:(NSArray *)points;
+ (NSArray *)translate:(NSArray *)points to:(DollarPoint *)point;

- (DollarResult *)recognize:(NSArray *)points;
- (void)addGesture:(NSString *)name points:(NSArray *)points;

@end