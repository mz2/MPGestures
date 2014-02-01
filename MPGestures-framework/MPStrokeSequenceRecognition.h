#import <Foundation/Foundation.h>

@interface MPStrokeSequenceRecognition : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) float score;

- (instancetype)initWithName:(NSString *)name score:(float)score;

@end