#import "MPStrokeSequenceRecognition.h"

@implementation MPStrokeSequenceRecognition

- (instancetype)initWithName:(NSString *)name score:(float)score
{
    self = [super init];
    if (self) {
        _name = name;
        _score = score;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    
    [str appendFormat:@"<name:%@ ", _name];
    
    if (_correctName)
        [str appendFormat:@" (%@)", _correctName];
    
    [str appendFormat:@", score:%f", _score];
    
    if (_scores)
        [str appendFormat:@" (%@)", _scores];
    
    [str appendFormat:@">"];
    
    return [str copy];
}

@end