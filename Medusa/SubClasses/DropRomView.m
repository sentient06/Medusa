//
//  DropRomView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

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
