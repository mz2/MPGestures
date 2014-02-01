#import <Foundation/Foundation.h>

@interface MPStrokeSequenceRecognition : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) float score;

/**
 *  Marks the correct label when known.
 */
@property (nonatomic, readwrite) NSString *correctName;

/** A vector of scores for all the possible labels from which score was chosen as the optimal. */
@property (nonatomic, readwrite) NSArray *scores;

- (instancetype)initWithName:(NSString *)name score:(float)score;

@end