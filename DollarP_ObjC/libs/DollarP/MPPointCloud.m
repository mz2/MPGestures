#import "MPPointCloud.h"
#import "MPDollarPointCloudRecognizer.h"

@implementation MPPointCloud

- (instancetype)initWithName:(NSString *)aName
                      points:(NSArray *)somePoints
           resampledToNumber:(NSUInteger)numPoints
             normalizedScale:(BOOL)normalizedScale
        differenceToCentroid:(MPPoint *)translationPoint
{
    self = [super init];
    if (self) {
        [self setName:aName];
        
        if (numPoints > 0)
            somePoints = [MPDollarPointCloudRecognizer resample:somePoints numPoints:numPoints];
        
        if (normalizedScale)
            somePoints = [MPDollarPointCloudRecognizer scale:somePoints];
        
        if (translationPoint)
            somePoints = [MPDollarPointCloudRecognizer translate:somePoints to:translationPoint];
        
        [self setPoints:somePoints];
    }
    return self;
}

@end