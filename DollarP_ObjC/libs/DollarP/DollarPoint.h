#import <Foundation/Foundation.h>

@interface DollarPoint : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) id id;

@property (readonly) CGPoint CGPointValue;

+ (DollarPoint *)origin;

- (instancetype)initWithId:(id)id x:(float)x y:(float)y;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryRepresentation;

+ (NSArray *)pointsWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end