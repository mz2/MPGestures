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

@implementation MPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.window makeFirstResponder:self.gestureView];
    self.gestureLabel.stringValue = @"";
    
    
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

- (void)gestureView:(MPGestureView *)gestureView didDetectGesture:(DollarResult *)result
{
    self.gestureLabel.stringValue = result.name;
}

- (IBAction)addExample:(id)sender
{
    
}

@end
