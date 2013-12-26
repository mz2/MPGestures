#import <Foundation/Foundation.h>

@class MPPoint;

static const NSInteger DollarPNumResampledPoints = 32;

@interface MPPointCloud : NSObject 

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *points;

/**
 *  Initialises a point cloud
 *
 *  @param aName            A name label for the point cloud.
 *  @param somePoints       An array of DollarPoints to resample from to form the point cloud.
 *  @param numPoints        A fixed number of resamples for the point cloud.
 *  @param normalizedScale  Normalize the scale to Z-scores.
 *  @param translationPoint Translate the point cloud to a difference from its centroid.
 *
 *  @return A point cloud representing scaled, translated resamples from the incoming point array.
 */
- (instancetype)initWithName:(NSString *)aName
                      points:(NSArray *)somePoints
           resampledToNumber:(NSUInteger)numPoints
             normalizedScale:(BOOL)normalizedScale
        differenceToCentroid:(MPPoint *)translationPoint;

@end