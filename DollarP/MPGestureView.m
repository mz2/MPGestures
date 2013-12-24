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

const NSTimeInterval MPGestureViewStrokesEndedInterval = 1.0f;

@interface MPGestureView ()

@property NSMutableArray *strokes;

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

- (void)setup {
    _strokes = [[NSMutableArray alloc] init];
    
    //[self setBackgroundColor:[UIColor whiteColor]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, 5.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (int i = 0; i < _strokes.count; i++) {
        DollarStroke *stroke = _strokes[i];
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
    
    if (!_strokes)
        _strokes = [[NSMutableArray alloc] initWithCapacity:5];
    
    DollarStroke *stroke = [[DollarStroke alloc] init];
    [stroke addPoint:p identifier:1];
    
    [_strokes addObject:stroke];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [[_strokes lastObject] addPoint:p identifier:_strokes.count];
    
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
    
    NSArray *ps = [[_strokes valueForKey:@"pointsArray"] valueForKeyPath:@"@unionOfArrays.self"];
    
    NSLog(@"Point: %@", ps);
    
    DollarResult *result = [dp recognize:ps];
    NSLog(@"Result: %@ (score: %.2f)", result.name, result.score);
    
    [self.delegate gestureView:self didDetectGesture:result];
    
    _strokes = nil;
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


- (void)clearAll {
    [_strokes removeAllObjects];
    [self setNeedsDisplay:YES];
}

@end
