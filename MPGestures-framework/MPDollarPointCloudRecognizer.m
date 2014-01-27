#import "MPDollarPointCloudRecognizer.h"
#import "MPPointCloud.h"

#import "MPStrokeSequence.h"

@implementation MPDollarPointCloudRecognizer

@synthesize pointClouds;

- (id)init {
    self = [super init];
    if (self) {
        pointClouds = [NSMutableArray array];
        _resampleRate = MPPointCloudDefaultResampleRate;
    }
    return self;
}

+ (NSArray *)processPoints:(NSArray *)points
          atResamplingRate:(NSUInteger)resampleRate
{
    assert(resampleRate > 8);
    points = [[self class] resample:points numPoints:resampleRate];
    points = [[self class] scale:points];
    points = [[self class] translate:points to:[MPPoint origin]];
    return points;
}

+ (float)scoreForGreedyCloudMatchOfPointCloud:(MPPointCloud *)pointCloud
                                 withTemplate:(MPPointCloud *)templatePointCloud
                               atResamplerate:(NSUInteger)resampleRate {
    NSArray *points = nil;
    if (resampleRate)
        points = [self processPoints:pointCloud.points atResamplingRate:resampleRate];
    else
        points = pointCloud.points;
    
    float d = [[self class] greedyCloudMatch:points template:templatePointCloud.points];
    float score = MAX((d - 2.0f) / -2.0f, 0.0f);
    return score;
}

- (MPStrokeSequenceRecognition *)recognize:(NSArray *)points {
    MPStrokeSequenceRecognition *result = [[MPStrokeSequenceRecognition alloc] init];
    [result setName:@"No match"];
    [result setScore:0.0];
    
    if (!points.count) {
        return result;
    }
    
    points = [[self class] processPoints:points atResamplingRate:_resampleRate];
    
    float b = +INFINITY;
    int u = -1;
    
    for (int i = 0; i < [[self pointClouds] count]; i++) {
        float d = [[self class] greedyCloudMatch:points template:[[self pointClouds][i] points]];
        if (d < b) {
            b = d;
            u = i;
        }
    }
    
    float score = MAX((b - 2.0f) / -2.0f, 0.0f);
    
    if (u != -1) {
        [result setName:[[self pointClouds][u] name]];
        [result setScore:score];
    }
    
    return result;
}

- (void)setPointClouds:(NSMutableArray *)somePointClouds {
    pointClouds = [somePointClouds mutableCopy];
}

- (void)addGesture:(NSString *)name
            points:(NSArray *)points {
    MPPointCloud *pointCloud = [[MPPointCloud alloc] initWithName:name
                                                           points:points
                                                resampledToNumber:self.resampleRate
                                                  normalizedScale:YES
                                             differenceToCentroid:[MPPoint origin]];
    [[self pointClouds] addObject:pointCloud];
}

- (void)addStrokeSequence:(MPStrokeSequence *)sequence {
    MPPointCloud *pointCloud = [sequence pointCloudRepresentationWithResampleCount:self.resampleRate];
    
    // FIXME: make it a map of point clouds by name.
    BOOL matchingNameExists = [[self.pointClouds filteredArrayUsingPredicate:
      [NSPredicate predicateWithBlock:
       ^BOOL(MPPointCloud *cloud, NSDictionary *bindings) {
           return [cloud.name isEqualToString:sequence.name];
    }]] firstObject] != nil;
    
    if (matchingNameExists)
        pointCloud.name
            = [NSString stringWithFormat:@"%@-%@", sequence.name, sequence.signature];
    
    [[self pointClouds] addObject:pointCloud];
}

- (MPStrokeSequenceRecognition *)recognizeStrokeSequence:(MPStrokeSequence *)seq {
    MPPointCloud *pointCloud = [seq pointCloudRepresentationWithResampleCount:self.resampleRate];
    return [self recognize:pointCloud.points];
}

+ (float)greedyCloudMatch:(NSArray *)points
                 template:(NSArray *)template {
    float e = 0.50f;
	float step = floor(pow([points count], 1 - e));
	float min = +INFINITY;
    
	for (int i = 0; i < [points count]; i += step) {
		float d1 = [self cloudDistanceFrom:points to:template start:i];
		float d2 = [self cloudDistanceFrom:template to:points start:i];
		min = MIN(min, MIN(d1, d2));
	}
    
	return min;
}

+ (float)cloudDistanceFrom:(NSArray *)points1
                        to:(NSArray *)points2
                     start:(int)start {
    NSUInteger numPoints1 = [points1 count];
    NSUInteger numPoints2 = [points2 count];
    
    if (numPoints1 < 1)
        return NAN;
    
    NSMutableArray *matched = [NSMutableArray arrayWithCapacity:numPoints1];
	for (int k = 0; k < numPoints1; k++) {
		matched[k] = @NO;
    }
    
	float sum = 0.0f;
	int i = start;
    
	do {
		int index = -1;
		float min = +INFINITY;
        
		for (int j = 0; j < [matched count]; j++) {
			if (![matched[j] boolValue]) {
                if (i < numPoints1 && j < numPoints2) {
                    float d = [self distanceFrom:points1[i] to:points2[j]];
                    if (d < min) {
                        min = d;
                        index = j;
                    }
                }
			}
		}

        if (index > -1) {
            matched[index] = @YES;
        }
        
		float weight = 1 - ((i - start + numPoints1) % numPoints1) / numPoints1;
		sum += weight * min;
		i = (i + 1) % numPoints1;
        
	} while (i != start);
    
	return sum;
}

+ (NSArray *)resample:(NSArray *)points
            numPoints:(NSUInteger)numPoints {
    float I = [self pathLength:points] / (numPoints - 1);
	float D = 0.0f;
    
    NSMutableArray *thePoints = [points mutableCopy];
	NSMutableArray *newPoints = [NSMutableArray arrayWithObject:thePoints[0]];

	for (int i = 1; i < [thePoints count]; i++) {
        MPPoint *prevPoint = thePoints[i - 1];
        MPPoint *thisPoint = thePoints[i];

		if ([thisPoint id] == [prevPoint id]) {
			float d = [self distanceFrom:prevPoint to:thisPoint];
            
			if ((D + d) >= I) {
				float qx = [prevPoint x] + ((I - D) / d) * ([thisPoint x] - [prevPoint x]);
				float qy = [prevPoint y] + ((I - D) / d) * ([thisPoint y] - [prevPoint y]);
                
				MPPoint *q = [[MPPoint alloc] initWithId:[thisPoint id] x:qx y:qy];
                
				[newPoints addObject:q];
				[thePoints insertObject:q atIndex:i];
				D = 0.0f;
			} else {
                D += d;
            }
		}
	}
    
	if ([newPoints count] == numPoints - 1) {
        MPPoint *lastPoint = thePoints[[thePoints count] - 1];
		[newPoints addObject:[lastPoint copy]];
    }
    
	return newPoints;
}

+ (NSArray *)scale:(NSArray *)points {
    float minX = +INFINITY;
    float maxX = -INFINITY;
    float minY = +INFINITY;
    float maxY = -INFINITY;
    
    MPPoint *thisPoint;
	for (int i = 0; i < [points count]; i++) {
        thisPoint = points[i];
		minX = MIN(minX, [thisPoint x]);
		minY = MIN(minY, [thisPoint y]);
		maxX = MAX(maxX, [thisPoint x]);
		maxY = MAX(maxY, [thisPoint y]);
	}
    
	float size = MAX(maxX - minX, maxY - minY);
	NSMutableArray *newPoints = [NSMutableArray array];
    
	for (int i = 0; i < [points count]; i++) {
        thisPoint = points[i];
        
		float qx = ([thisPoint x] - minX) / size;
		float qy = ([thisPoint y] - minY) / size;
        
        MPPoint *q = [[MPPoint alloc] initWithId:[thisPoint id] x:qx y:qy];
        
        [newPoints addObject:q];
	}
    
	return newPoints;
}

+ (NSArray *)translate:(NSArray *)points
                    to:(MPPoint *)point {
    MPPoint *c = [[self class] centroid:points];
	NSMutableArray *newPoints = [NSMutableArray array];
    
	for (int i = 0; i < [points count]; i++) {
        MPPoint *thisPoint = points[i];
        
		float qx = [thisPoint x] + [point x] - [c x];
		float qy = [thisPoint y] + [point y] - [c y];
        
        MPPoint *q = [[MPPoint alloc] initWithId:[thisPoint id] x:qx y:qy];
        
        [newPoints addObject:q];
	}
    
	return newPoints;
}

+ (MPPoint *)centroid:(NSArray *)points {
    float x = 0.0f;
    float y = 0.0f;
    
	for (int i = 0; i < [points count]; i++) {
        MPPoint *thisPoint = points[i];
        
		x += [thisPoint x];
		y += [thisPoint y];
	}
    
	x /= [points count];
	y /= [points count];
    
    return [[MPPoint alloc] initWithId:0 x:x y:y];
}

+ (float)pathDistanceFrom:(NSArray *)points1
                       to:(NSArray *)points2 {
    float d = 0.0f;
    
	for (int i = 0; i < [points1 count]; i++) {
		d += [self distanceFrom:points1[i] to:points2[i]];
    }
    
	return d / [points1 count];
}

+ (float)pathLength:(NSArray *)points {
	float d = 0.0f;
    
	for (int i = 1; i < [points count]; i++) {
        MPPoint *prevPoint = points[i - 1];
        MPPoint *thisPoint = points[i];
        
		if ([thisPoint id] == [prevPoint id]) {
			d += [self distanceFrom:prevPoint to:thisPoint];
        }
	}
    
	return d;
}

+ (float)distanceFrom:(MPPoint *)point1
                   to:(MPPoint *)point2 {
    float dx = [point2 x] - [point1 x];
    float dy = [point2 y] - [point1 y];
    
    return sqrt(dx * dx + dy * dy);
}

@end