//
//  MPGestureViewController.m
//  DollarP_ObjC
//
//  Created by Matias Piipari on 26/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPGestureViewController.h"
#import "NSFileManager+ApplicationSupport.h"

#import "MPStrokeSequenceDatabase.h"
#import "MPPointCloudRecognition.h"
#import "MPStrokeSequence.h"

#import "MPStrokeSequenceDatabaseSynchronizer.h"

@interface MPGestureViewController ()
@property MPStrokeSequence *strokeSequence;
@end

@implementation MPGestureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (MPGestureView *)gestureView
{
    assert(!self.view || [self.view isKindOfClass:[MPGestureView class]]);
    return (MPGestureView *)self.view;
}

- (void)awakeFromNib
{
    [self.view.window makeFirstResponder:self.gestureView];
    self.statusLabel.stringValue = @"";
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self strokeSequencePath]])
    {
        // FIXME: make the identifier configurable when creating a new database.
        self.db = [[MPStrokeSequenceDatabase alloc] initWithIdentifier:NSUserName()];
        
    }
    else
    {
        NSError *err = nil;
        self.db = [[MPStrokeSequenceDatabase alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[self strokeSequencePath]] error:&err];
        
        [[MPStrokeSequenceDatabaseSynchronizer sharedInstance] continuouslySynchronizeDatabase:self.db];
        
        if (err)
        {
            NSLog(@"Failed to initialise stroke sequence database");
            [[NSAlert alertWithError:err] runModal];
        }
    }
    
    [_previousGestureButton setEnabled:NO];
    [_nextGestureButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(databaseDidChangeExternally:)
                                                 name:MPStrokeSequenceDatabaseChangedExternallyNotification
                                               object:self.db];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)strokeSequencePath
{
    NSString *userName = NSUserName();
    return [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@.strokedb", userName]];
}

#pragma mark - Gesture database persistence

- (void)persistStrokeSequenceDatabase
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSError *err = nil;
                       
                       if (![self.db writeToURL:[NSURL fileURLWithPath:self.strokeSequencePath] error:&err])
                       {
                           [[NSAlert alertWithError:err] runModal];
                       }
                       else
                       {
                           NSLog(@"Database now has %lu labeled stroke sequences for %lu different labels:\nnames:%@",
                                 self.db.strokeSequenceSet.count,
                                 self.db.strokeSequenceNameSet.count,
                                 self.db.strokeSequenceNameSet);
                       }
                   });
}


#pragma mark - Gesture view delegate

- (void)gestureView:(MPGestureView *)gestureView
     didStartStroke:(MPStroke *)stroke
   inStrokeSequence:(MPStrokeSequence *)strokeSequence
{
    if (!_strokeSequence || _strokeSequence != strokeSequence)
        _strokeSequence = strokeSequence;
    
    [self.gestureTextfield setEnabled:NO];
    [self.gestureTextfield setHidden:YES];
    [self.submitGestureButton setEnabled:NO];
    [self.submitGestureButton setHidden:YES];
}

- (void)gestureView:(MPGestureView *)gestureView
 didFinishDetection:(MPPointCloudRecognition *)result
 withStrokeSequence:(MPStrokeSequence *)strokeSequence
{
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Detected as %@", result.name];
    self.strokeSequence = strokeSequence;
    
    [self.gestureTextfield setEnabled:YES];
    [self.gestureTextfield setHidden:NO];
    
    [self.submitGestureButton setEnabled:self.gestureLabelEntered];
    [self.submitGestureButton setHidden:NO];
}

#pragma mark - UI updating 

- (BOOL)gestureLabelEntered
{
    return self.gestureTextfield.stringValue.length > 0;
}


- (void)refresh
{
    if (self.gestureView.additionalStrokeSequences.count == 0
        || self.gestureView.selectedAdditionalStrokeSequenceIndex == NSNotFound)
    {
        [self.nextGestureButton setEnabled:NO];
        [self.previousGestureButton setEnabled:NO];
    }
    else if (self.gestureView.selectedAdditionalStrokeSequenceIndex != NSNotFound)
    {
        [self.nextGestureButton setEnabled:self.gestureView.selectedAdditionalStrokeSequenceIndex
         < (self.gestureView.additionalStrokeSequences.count - 1)];
        
        [self.previousGestureButton setEnabled:self.gestureView.selectedAdditionalStrokeSequenceIndex > 0];
    }
    
    [self.deleteGestureButton setEnabled:self.gestureView.selectedAdditionalStrokeSequenceIndex != NSNotFound];
    
    [self.gestureView setNeedsDisplay:YES];
}



#pragma mark - Actions

- (void)addExample:(id)sender
{
    if (self.gestureView.isStroking)
    {
        NSBeep();
        return;
    }
    
    if (!self.gestureLabelEntered)
    {
        NSBeep();
        return;
    }
    
    MPStrokeSequence *seq = [[MPStrokeSequence alloc] initWithName:self.gestureTextfield.stringValue strokes:self.strokeSequence.strokesArray];
    
    if (seq.strokeCount == 0)
    {
        NSBeep();
        return;
    }
    
    [self.db addStrokeSequence:seq];
    
    self.strokeSequence = nil;
    
    [self.labelComboBox reloadData];
    [self.gestureView clear:self];
    
    [self persistStrokeSequenceDatabase];
}



- (IBAction)nextStrokeSequence:(id)sender
{
    [self.gestureView selectAdditionalStrokeSequenceAtIndex:self.gestureView.selectedAdditionalStrokeSequenceIndex + 1];
    
    [self refresh];
}

- (IBAction)previousStrokeSequence:(id)sender
{
    [self.gestureView selectAdditionalStrokeSequenceAtIndex:self.gestureView.selectedAdditionalStrokeSequenceIndex - 1];
    
    [self refresh];
}

- (IBAction)deleteStrokeSequence:(id)sender
{
    if (self.gestureView.selectedAdditionalStrokeSequenceIndex != NSNotFound)
    {
        MPStrokeSequence *selectedSeq
        = self.gestureView.additionalStrokeSequences
        [self.gestureView.selectedAdditionalStrokeSequenceIndex];
        
        [self.db removeStrokeSequence:selectedSeq];
        
        self.gestureView.additionalStrokeSequences =
        [self.gestureView.additionalStrokeSequences filteredArrayUsingPredicate:
                [NSPredicate predicateWithBlock:
                 ^BOOL(MPStrokeSequence *seq, NSDictionary *bindings)
        {
            return seq != selectedSeq;
        }]];
        
        NSInteger i = self.gestureView.selectedAdditionalStrokeSequenceIndex - 1;
        
        if (i >= 0)
            [self.gestureView selectAdditionalStrokeSequenceAtIndex:i];
        else if (self.gestureView.additionalStrokeSequences.count > 0)
            i = 0;
        else
            [self.gestureView selectAdditionalStrokeSequenceAtIndex:NSNotFound];
        
        [self refresh];
        
        [self persistStrokeSequenceDatabase];
    }
}

#pragma mark - Combo box delegate & data source

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return self.db.strokeSequenceNameSet.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return self.db.sortedStrokeSequenceNames[index];
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    return [self.db.sortedStrokeSequenceNames indexOfObject:string];
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)completedString
{
    return [[[self.db.sortedStrokeSequenceNames filteredArrayUsingPredicate:
              [NSPredicate predicateWithBlock:^BOOL(NSString *string, NSDictionary *bindings)
               {
                   return [[string lowercaseString] hasPrefix:[completedString lowercaseString]];
               }]] sortedArrayUsingComparator:^NSComparisonResult(NSString *strA, NSString *strB) {
                   int aDiff = abs((int)strA.length - (int)completedString.length);
                   int bDiff = abs((int)strB.length - (int)completedString.length);
                   
                   return [@(aDiff) compare:@(bDiff)];
               }] firstObject];
}



- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSInteger i = self.labelComboBox.indexOfSelectedItem;
    
    if (i == NSNotFound || i < 0)
        return;
    
    NSString *name = self.db.sortedStrokeSequenceNames[i];
    
    NSLog(@"Selected %@ (%lu strokes)", name, [self.db[name] count]);
    
    if ([self.gestureView.additionalStrokeSequences isEqual:self.db[name]])
        return;
    
    self.gestureView.additionalStrokeSequences = [self.db[name] allObjects];
    
    [self.gestureView selectAdditionalStrokeSequenceAtIndex:0];
    
    [self.labelComboBox resignFirstResponder];
    
    [self refresh];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self.submitGestureButton setEnabled:self.gestureLabelEntered];
}

#pragma mark - 

- (void)databaseDidChangeExternally:(NSNotification *)obj
{
    MPStrokeSequenceDatabase *db = obj.object;
    assert(db == self.db);
    
    [self refresh];
}

@end