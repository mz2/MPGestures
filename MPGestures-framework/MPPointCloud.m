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
        _name = aName;
        
        if (numPoints > 0)
            somePoints = [MPDollarPointCloudRecognizer resample:somePoints numPoints:numPoints];
        
        if (normalizedScale)
            somePoints = [MPDollarPointCloudRecognizer normalizeScale:somePoints];
        
        if (translationPoint)
            somePoints = [MPDollarPointCloudRecognizer translate:somePoints to:translationPoint];
        
        _points = somePoints;
    }
    return self;
}

@end