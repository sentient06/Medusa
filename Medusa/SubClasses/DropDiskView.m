//
//  DropDiskView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
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

#import "DropDiskView.h"
#import "FileHandler.h"
#import "DriveModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation DropDiskView

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard * pboard    = [sender draggingPasteboard];
    NSArray      * urls      = [pboard propertyListForType:NSFilenamesPboardType];
    DriveModel   * diskObject = [[DriveModel alloc] autorelease];
    
    [diskObject parseDriveFilesAndSave:urls];
    
    return YES;
}

//- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
//    
//    NSPasteboard *pboard = [sender draggingPasteboard];
//    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];    
//    
//    NSString *pathExtension;
//    NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
//    
//    NSArray * acceptedExtensions = [[NSArray alloc] initWithObjects:
//          @"Unix Executable File"
//        , @"Document"
//        , @"NDIF Disk Image"
//        , @"Disk Image"
//        , nil
//    ];
//    
//    for (int i = 0; i < [urls count]; i++) {
//    
//        pathExtension = [[urls objectAtIndex:i] pathExtension];
//        
//        DDLogVerbose(@"Extension is %@", [pathExtension lowercaseString]);
//        
//        if ( [acceptedExtensions containsObject: [pathExtension lowercaseString]] ) {
//            
//            DrivesModel * drivesModel = [
//                NSEntityDescription
//                insertNewObjectForEntityForName:@"Drives"
//                         inManagedObjectContext:managedObjectContext
//            ];
//
//            //insertNewObjectInManagedObjectContext
//            [drivesModel setFilePath:[urls objectAtIndex:i]];
//            [drivesModel setFileName:[[urls objectAtIndex:i] lastPathComponent]];
//            
//            DDLogVerbose(@"Saving...");
//            NSError *error;
//            if (![managedObjectContext save:&error]) {
//                DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
//                DDLogVerbose(@"Check 'drop disk view' subclass.");
//            }
//
//        }
//        
//    }
//    
//    [acceptedExtensions release];
//    
//    return YES;
//    
//}

@end
