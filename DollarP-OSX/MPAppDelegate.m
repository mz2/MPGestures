//
//  MPAppDelegate.m
//  DollarP-OSX
//
//  Created by Matias Piipari on 24/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPGestureView.h"
#import "DollarResult.h"
#import "DollarStrokeSequence.h"

@interface MPAppDelegate ()
@property DollarStrokeSequence *strokeSequence;
@end

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.window makeFirstResponder:self.gestureView];
    self.statusLabel.stringValue = @"";
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self strokeSequencePath]])
    {
        self.db = [[DollarStrokeSequenceDatabase alloc] initWithDictionary:@{}];
        
        [self.db dictionaryRepresentation];
    }
    else
    {
        NSError *err = nil;
        self.db = [[DollarStrokeSequenceDatabase alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[self strokeSequencePath]] error:&err];
        
        if (err)
        {
            NSLog(@"Failed to initialise stroke sequence database");
            [[NSAlert alertWithError:err] runModal];
        }
    }
    
    [_previousGestureButton setEnabled:NO];
    [_nextGestureButton setEnabled:NO];
}


// FIXME: move to a category.
- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         searchPathDirectory,
                                                         domainMask,
                                                         YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }
    
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
    {
        resolvedPath = [resolvedPath
                        stringByAppendingPathComponent:appendComponent];
    }
    
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]
                    createDirectoryAtPath:resolvedPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
    if (!success) 
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result =
    [self
     findOrCreateDirectory:NSApplicationSupportDirectory
     inDomain:NSUserDomainMask
     appendPathComponent:executableName
     error:&error];
    if (error)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

- (NSString *)strokeSequencePath
{
    NSString *userName = NSUserName();
    return [[self applicationSupportDirectory] stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@.strokedb", userName]];
}

- (void)gestureView:(MPGestureView *)gestureView
     didStartStroke:(DollarStroke *)stroke
   inStrokeSequence:(DollarStrokeSequence *)strokeSequence
{
    if (!_strokeSequence || _strokeSequence != strokeSequence)
        _strokeSequence = strokeSequence;
    
    [self.gestureTextfield setEnabled:NO];
    [self.gestureTextfield setHidden:YES];
    [self.submitGestureButton setEnabled:NO];
    [self.submitGestureButton setHidden:YES];
}

- (void)gestureView:(MPGestureView *)gestureView
 didFinishDetection:(DollarResult *)result
 withStrokeSequence:(DollarStrokeSequence *)strokeSequence
{
    self.statusLabel.stringValue = [NSString stringWithFormat:@"Detected as %@", result.name];
    self.strokeSequence = strokeSequence;
    
    [self.gestureTextfield setEnabled:YES];
    [self.gestureTextfield setHidden:NO];
    
    [self.submitGestureButton setEnabled:self.gestureLabelEntered];
    [self.submitGestureButton setHidden:NO];
}

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
    
    DollarStrokeSequence *seq = [[DollarStrokeSequence alloc] initWithName:self.gestureTextfield.stringValue strokes:self.strokeSequence.strokesArray];
    
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

- (BOOL)gestureLabelEntered
{
    return self.gestureTextfield.stringValue.length > 0;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self.submitGestureButton setEnabled:self.gestureLabelEntered];
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
        DollarStrokeSequence *selectedSeq
            = self.gestureView.additionalStrokeSequences
               [self.gestureView.selectedAdditionalStrokeSequenceIndex];
        [self.db[selectedSeq.name] removeObject:selectedSeq];
        
        self.gestureView.additionalStrokeSequences = [self.gestureView.additionalStrokeSequences filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
            ^BOOL(DollarStrokeSequence *seq, NSDictionary *bindings)
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

@end