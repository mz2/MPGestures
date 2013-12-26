//
//  NSFileManager+ApplicationSupport.h
//  DollarP_ObjC
//
//  Created by Matias Piipari on 26/12/2013.
//  Copyright (c) 2013 de.ur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ApplicationSupport)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;

- (NSString *)applicationSupportDirectory;

@end
