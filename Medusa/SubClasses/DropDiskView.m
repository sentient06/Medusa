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
#import "DrivesModel.h" //Model that handles all Drives-Entity-related objects.

@implementation DropDiskView

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];    
    
    NSString *pathExtension;
    NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    for (int i = 0; i < [urls count]; i++) {
    
        pathExtension = [[urls objectAtIndex:i] pathExtension];
        
        if (
            [[pathExtension lowercaseString]    isEqualTo:@"hfv"]   ||
            [[pathExtension lowercaseString]    isEqualTo:@"dsk"]   ||
            [[pathExtension lowercaseString]    isEqualTo:@"dmg"]   ||
            [[pathExtension lowercaseString]    isEqualTo:@"img"]   ||
            [[pathExtension lowercaseString]    isEqualTo:@"image"] ||
            [[pathExtension lowercaseString]    isEqualTo:@""]
        ) {
            
            DrivesModel *drivesModel = [
                NSEntityDescription
                insertNewObjectForEntityForName:@"Drives"
                         inManagedObjectContext:managedObjectContext
            ];
            //insertNewObjectInManagedObjectContext
            [drivesModel setFilePath:[urls objectAtIndex:i]];
            [drivesModel setFileName:[[urls objectAtIndex:i] lastPathComponent]];
            
            NSLog(@"Saving...");
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                NSLog(@"Check 'drop disk view' subclass.");
            }
                
        }
        
    }
    
    return YES;
    
}

@end
