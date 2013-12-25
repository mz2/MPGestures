//
//  GestureView.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPGestureView.h"
#import "DollarStroke.h"
#import "DollarP.h"
#import "DollarDefaultGestures.h"

#import "DollarStrokeSequence.h"

const NSTimeInterval MPGestureViewStrokesEndedInterval = 1.0f;

@interface MPGestureView ()

@property DollarStrokeSequence *strokeSequence;

@property NSTimer *strokesEndedTimer;

@end

@implementation MPGestureView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, 5.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (int i = 0; i < _strokeSequence.strokesArray.count; i++) {
        DollarStroke *stroke = _strokeSequence.strokesArray[i];
        [self drawStroke:stroke inContext:context];
    }
}

- (void)drawStroke:(DollarStroke *)stroke
         inContext:(CGContextRef)context
{
    [[stroke color] set];
    
    NSArray *points = [stroke pointsArray];
    CGPoint point = [points[0] CGPointValue];
    
    CGContextFillRect(context, CGRectMake(point.x - 5, point.y - 5, 10, 10));
    
    CGContextMoveToPoint(context, point.x, point.y);
    for (int i = 1; i < [points count]; i++) {
        point = [points[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}

- (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [_strokesEndedTimer invalidate];
    _strokesEndedTimer = nil;
    
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    if (!_strokeSequence)
        _strokeSequence = [[DollarStrokeSequence alloc] initWithName:nil strokes:@[]];
    
    DollarStroke *stroke = [[DollarStroke alloc] init];
    [stroke addPoint:p identifier:1];
    
    [_strokeSequence addStroke:stroke];
    [_delegate gestureView:self didStartStroke:stroke inStrokeSequence:_strokeSequence];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    assert(_strokeSequence);
    [[_strokeSequence lastStroke] addPoint:p identifier:_strokeSequence.strokeCount];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self setNeedsDisplay:YES];
    
    _strokesEndedTimer = [NSTimer scheduledTimerWithTimeInterval:MPGestureViewStrokesEndedInterval
                                                          target:self
                                                        selector:@selector(strokesDidEnd:)
                                                        userInfo:nil repeats:NO];
}

- (void)strokesDidEnd:(NSTimer *)timer
{
    DollarP *dp = [[DollarP alloc] init];
    dp.pointClouds = [DollarDefaultGestures defaultPointClouds];
    
    NSArray *ps = [[_strokeSequence.strokesArray valueForKey:@"pointsArray"] valueForKeyPath:@"@unionOfArrays.self"];
    
    NSLog(@"Points:\n%@", ps);
    
    DollarResult *result = [dp recognize:ps];
    NSLog(@"Result: %@ (score: %.2f)", result.name, result.score);
    
    [self.delegate gestureView:self didFinishDetection:result withStrokeSequence:_strokeSequence];
    
    _strokeSequence = nil;
    _strokesEndedTimer = nil;
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return self;
}

- (BOOL)acceptsTouchEvents
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSLog(@"Moved");
}

@end
