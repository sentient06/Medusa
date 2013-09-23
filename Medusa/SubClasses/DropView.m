//
//  DropView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 28/02/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------

#import "DropView.h"
#import "FileHandler.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation DropView

@synthesize computerModel;
@synthesize acceptedTypes;

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric) {

        return NSDragOperationCopy;
    } else {
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    
    BOOL returnValue;
    
    //All pasteboard:
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];
    
    
    //Old code
    //------------------------------------
    /*
    //First element only:
    NSString *firstElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:0]];
    NSString *pathExtension = [[NSString alloc] initWithFormat:[firstElement pathExtension]];
    
    //Check if is a folder:
    BOOL isDir;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    [fileManager fileExistsAtPath:firstElement isDirectory:&isDir];
    
    NSString *kind = nil;
    NSURL *url = [NSURL fileURLWithPath:[firstElement stringByExpandingTildeInPath]];
    LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
    
    DDLogVerbose(@"%@", kind);
    computerModel = @"Test";
    //DDLogVerbose(@"%@", parent);

    if (
        [kind isEqualToString:@"Unix Executable File"] ||
        [kind isEqualToString:@"Document"]
    ) {
        returnValue = YES;
    }else{
        returnValue = NO;
    }
        
    
    [fileManager release];
    [pathExtension release];
    [firstElement release];
    
    */
    //------------------------------------
    //New code
    //First element only:
    
    NSString *firstElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:0]];
    
    NSString *currentElement;
    //NSString *pathExtension;
    BOOL isDir;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *kind;
    NSURL *url;
    
    returnValue = NO;
    
    for (int i=0; i<[urls count]; i++) {

        currentElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:i]];
        //pathExtension  = [[NSString alloc] initWithFormat:[currentElement pathExtension]];

        //Check if is a folder:
        
        [fileManager fileExistsAtPath:currentElement isDirectory:&isDir];
        
        kind = nil;
        url = [NSURL fileURLWithPath:[firstElement stringByExpandingTildeInPath]];
        LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
        
        DDLogVerbose(@"kind is %@", kind);
        computerModel = @"Test";
        
        [currentElement release];
        
        if (
            [kind isEqualToString:@"Unix Executable File"] ||
            [kind isEqualToString:@"Document"] ||
            [kind isEqualToString:@"NDIF Disk Image"] ||
            [kind isEqualToString:@"Disk Image"]
        ) {
            returnValue = YES;
            break;
        }
        
    }
    
    [fileManager release];
    //[pathExtension release];
    [firstElement release];
    
    return returnValue;
    
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {

    return YES;
    
}

@end
