#import "DollarPointCloud.h"
#import "DollarP.h"

@implementation DollarPointCloud

- (instancetype)initWithName:(NSString *)aName
                      points:(NSArray *)somePoints
           resampledToNumber:(NSUInteger)numPoints
             normalizedScale:(BOOL)normalizedScale
        differenceToCentroid:(DollarPoint *)translationPoint
{
    self = [super init];
    if (self) {
        [self setName:aName];
        
        if (numPoints > 0)
            somePoints = [DollarP resample:somePoints numPoints:numPoints];
        
        if (normalizedScale)
            somePoints = [DollarP scale:somePoints];
        
        if (translationPoint)
            somePoints = [DollarP translate:somePoints to:translationPoint];
        
        [self setPoints:somePoints];
    }
    return self;
}

@end