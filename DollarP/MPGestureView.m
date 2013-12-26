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

@property DollarStrokeSequence *currentStrokeSequence;

@property DollarStrokeSequence *lastStrokeSequence;

@property NSTimer *strokesEndedTimer;

@property (readwrite) NSUInteger selectedAdditionalStrokeSequenceIndex;

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
    
    _selectedAdditionalStrokeSequenceIndex = NSNotFound;
}

- (void)setup
{
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, 5.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // draw additional strokes first (so they're drawn faintly under the last / currently drawn)
    for (NSUInteger i = 0; i < self.additionalStrokeSequences.count; i++) {
        DollarStrokeSequence *seq = self.additionalStrokeSequences[i];
        
        for (NSUInteger j = 0 ; j < seq.strokesArray.count; j++) {
            DollarStroke *stroke = [self.additionalStrokeSequences[i] strokesArray][j];
            [self drawStroke:stroke inContext:context];
        }
    }
    
    // draw either the last (already finished) or the current (currently manipulated) stroke
    DollarStrokeSequence *strokeSequence
        = _lastStrokeSequence ? _lastStrokeSequence : _currentStrokeSequence;
    
    for (NSUInteger i = 0; i < strokeSequence.strokeCount; i++)
    {
        DollarStroke *stroke = strokeSequence.strokesArray[i];
        [self drawStroke:stroke inContext:context];
    }
}

- (void)drawStroke:(DollarStroke *)stroke
         inContext:(CGContextRef)context
{
    if ([_currentStrokeSequence containsStroke:stroke])
        [[stroke color] set];
    else if ([_lastStrokeSequence containsStroke:stroke])
        [[NSColor blackColor] set];
    else if (_selectedAdditionalStrokeSequenceIndex != NSNotFound
             && [_additionalStrokeSequences[_selectedAdditionalStrokeSequenceIndex] containsStroke:stroke])
        [[NSColor redColor] set];
    else
        [[NSColor colorWithWhite:0.0 alpha:0.2] set];
    
    
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

- (BOOL)isStroking
{
    return _currentStrokeSequence != nil;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [_strokesEndedTimer invalidate];
    _strokesEndedTimer = nil;
    _lastStrokeSequence = nil;
    
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    if (!_currentStrokeSequence)
    {
        _currentStrokeSequence = [[DollarStrokeSequence alloc] initWithName:nil strokes:@[]];
    }
    
    DollarStroke *stroke = [[DollarStroke alloc] init];
    [stroke addPoint:p identifier:1];
    stroke.color = [self randomColor];
    
    [_currentStrokeSequence addStroke:stroke];
    [_delegate gestureView:self didStartStroke:stroke inStrokeSequence:_currentStrokeSequence];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    assert(_currentStrokeSequence);
    assert(_currentStrokeSequence.strokeCount > 0);
    [[_currentStrokeSequence lastStroke] addPoint:p identifier:_currentStrokeSequence.strokeCount];
    
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
    
    NSArray *ps = [[_currentStrokeSequence.strokesArray valueForKey:@"pointsArray"] valueForKeyPath:@"@unionOfArrays.self"];
    
    NSLog(@"Points:\n%@", ps);
    
    DollarResult *result = [dp recognize:ps];
    NSLog(@"Result: %@ (score: %.2f)", result.name, result.score);
    
    [self.delegate gestureView:self didFinishDetection:result withStrokeSequence:_currentStrokeSequence];
    
    _lastStrokeSequence = _currentStrokeSequence;
    for (NSUInteger i = 0; i < _lastStrokeSequence.strokeCount; i++)
        [_lastStrokeSequence.strokesArray[i] setColor:[NSColor blackColor]];
    
    _currentStrokeSequence = nil;
    _strokesEndedTimer = nil;
    
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsTouchEvents
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (IBAction)clear:(id)sender
{
    _currentStrokeSequence = nil;
    _lastStrokeSequence = nil;
    [_strokesEndedTimer invalidate];
    _strokesEndedTimer = nil;
    
    [self setNeedsDisplay:YES];
}

- (void)selectAdditionalStrokeSequenceAtIndex:(NSUInteger)index
{
    self.selectedAdditionalStrokeSequenceIndex = index;
}

@end
