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
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_INFO;
//------------------------------------------------------------------------------

@implementation DropView

- (void)dealloc {
    [acceptedTypes release];
    [super dealloc];
}

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
    
    NSPasteboard * pboard = [sender draggingPasteboard];
    NSArray      * urls   = [pboard propertyListForType:NSFilenamesPboardType];
    
    //First element only:
    
    BOOL isDir;
    NSString      * firstElement = [[NSString alloc] initWithString:[urls objectAtIndex:0]];
    NSFileManager * fileManager  = [[NSFileManager alloc] init];
    NSString * kind;
    NSURL    * url;
    
    returnValue = NO;
    
    for (int i=0; i<[urls count]; i++) {
        
        NSString * currentElement = [urls objectAtIndex:i];
        
        //Checks if is a folder:        
        [fileManager fileExistsAtPath:currentElement isDirectory:&isDir];
        kind = nil;
        url = [NSURL fileURLWithPath:[firstElement stringByExpandingTildeInPath]];
        LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);

        DDLogVerbose(@"Dropped type is: %@", kind);
        DDLogVerbose(@"Accepted types: %@", acceptedTypes);
        
        if ([acceptedTypes containsObject:kind]) {
            returnValue = YES;
            break;
        }
        
    }
    
    [fileManager release];
    [firstElement release];
    
    return returnValue;
    
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (void)awakeFromNib {
    DDLogVerbose(@"init drop view");
    [super awakeFromNib];
    acceptedTypes = [[NSArray alloc] initWithObjects:
          @"Application"
        , @"Unix Executable File"
        , @"Document"
        , @"NDIF Disk Image"
        , @"Disk Image"
        , @"ROM Image"
        , @"Mac ROMan.app Document"
        , nil
    ];
}

@end
