#import "MPStrokeSequenceRecognition.h"

@implementation MPStrokeSequenceRecognition

- (id)initWithName:(NSString *)name score:(float)score
{
    self = [super init];
    if (self) {
        _name = name;
        _score = score;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<name:%@, score:%f>", _name, _score];
}

@end