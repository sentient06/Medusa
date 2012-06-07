//
//  DropRomView.m
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

#import "DropRomView.h"
#import "FileHandler.h"
#import "RomFilesModel.h" //Model that handles all Rom-Files-Entity-related objects.

@implementation DropRomView

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];


    /*------------------------------------------------------------------*\
     
     If the manager got this far, it means the file is a "Document" or a
     "Unix Executable File", which are the acceptable types of file to a
     ROM image. Here we must check the extension. It must be "rom" or
     nothing. After that we check the file binary data and find out if it
     is valid or not. If the file is not a ROM, it should be ignored.
     
    \*------------------------------------------------------------------*/
    
    //Must abstract all of this in a new class. -> Use CoreDataModel object.
    
    NSString *pathExtension;
    NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    for (int i = 0; i < [urls count]; i++) {
        
        pathExtension = [[urls objectAtIndex:i] pathExtension];
        
        
        if (
            [[pathExtension lowercaseString]    isEqualTo:@"rom"] ||
            [[pathExtension lowercaseString]    isEqualTo:@""]
        ) {
            
            
            
            FileHandler *aFileHandler = [[FileHandler alloc] init];
            
            [aFileHandler readRomFileFrom:[urls objectAtIndex:i]];
            
            
            // Core-data part:
            RomFilesModel *managedObject = [
                NSEntityDescription
                insertNewObjectForEntityForName: @"RomFiles"
                         inManagedObjectContext: managedObjectContext
            ];
            
            /// Here we have all the fields to be inserted.
            [managedObject setFilePath:[urls objectAtIndex:i]];
            [managedObject setModelName:[aFileHandler fileDetails]];
            [managedObject setComments:[aFileHandler comments]];
            
            if ( [[aFileHandler fileDetails] rangeOfString:@"Power Mac"].length ) {
                [managedObject setEmulator:@"Sheepshaver"];
            }
            
            [aFileHandler release];
            
            NSLog(@"Saving...");
            NSError *error;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                NSLog(@"Check 'drop rom view' subclass.");
            }
    
        }
        
    }

    return YES;
}


@end
