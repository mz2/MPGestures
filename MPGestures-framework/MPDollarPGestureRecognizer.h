#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "MPDollarPointCloudRecognizer.h"

@interface MPDollarPGestureRecognizer : UIGestureRecognizer {
    MPDollarPointCloudRecognizer *dollarP;
    NSMutableDictionary *currentTouches;
    NSMutableArray *currentPoints;
    NSMutableArray *points;
    int strokeId;
}

@property (nonatomic, strong) NSMutableArray *pointClouds;
@property (nonatomic, strong, readonly) MPStrokeSequenceRecognition *result;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)recognize;
- (void)addGestureWithName:(NSString *)name;
- (NSArray *)points;

@end