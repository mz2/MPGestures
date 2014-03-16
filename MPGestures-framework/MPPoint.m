#import "MPPoint.h"

@implementation MPPoint

@synthesize x, y, id;

+ (MPPoint *)origin {
    static MPPoint *origin = nil;
    if (!origin) {
        origin = [[MPPoint alloc] initWithId:0
                                               x:0.0f
                                               y:0.0f];
    }
    return origin;
}

- (instancetype)initWithId:(id)anId x:(float)aX y:(float)aY {
    self = [super init];
    if (self) {
        [self setId:anId];
        [self setX:aX];
        [self setY:aY];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.id = dictionary[@"id"];
        self.x = [dictionary[@"x"] floatValue];
        self.y = [dictionary[@"y"] floatValue];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MPPoint *point = [[MPPoint alloc] init];
    
    [point setX:[self x]];
    [point setY:[self y]];
    [point setId:[self id]];
    
    return point;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"id:%@ x:%f y:%f",
            [self id], [self x], [self y]];
}

- (CGPoint)CGPointValue
{
    return CGPointMake(self.x, self.y);
}

- (NSPoint)pointValue
{
    return NSMakePoint(self.x, self.y);
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{
                @"id":self.id,
                 @"x":@(self.x),
                 @"y":@(self.y)
            };
}

+ (NSArray *)pointsWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries
{
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:arrayOfDictionaries.count];
    for (NSDictionary *dict in arrayOfDictionaries)
    {
        assert([dict isKindOfClass:[NSDictionary class]]);
        [points addObject:[[MPPoint alloc] initWithDictionary:dict]];
    }
    
    return [points copy];
}

+ (float)leastSquaresEuclideanDistanceOfPoints:(NSArray *)pointsA
                                    withPoints:(NSArray *)pointsB
{
    float d = 0;
    
    if (pointsA.count != pointsB.count)
        @throw [NSException exceptionWithName:@"MPInvalidArgumentsException"
                                       reason:[NSString stringWithFormat:
                                               @"Mismatching point counts: %lu != %lu",
                                               (unsigned long)pointsA.count,
                                               (unsigned long)pointsB.count]
                                     userInfo:nil];
    
    for (NSUInteger i = 0; i < pointsA.count; i++)
    {
        MPPoint *a = pointsA[i];
        MPPoint *b = pointsB[i];
        d += powf(b.x - a.x, 2.f);
        d += powf(b.y - a.y, 2.f);
    }
    
    d = sqrtf(d);
    
    return d;
}

- (BOOL)isEqual:(MPPoint *)object
{
    if (!object)
        return NO;
    
    if (![self.id isEqual:object.id])
        return NO;
    
    float dist = [[self class] leastSquaresEuclideanDistanceOfPoints:@[self] withPoints:@[object]];
    
    return dist < 0.00001;
}

- (NSUInteger)hash
{
    const NSUInteger prime = 31;
    
    NSUInteger result = 1;
    
    result = prime * result + [self.id hash];
    result = prime * result + floor(self.x);
    result = prime * result + floor(self.y);
    
    return result;
}

@end