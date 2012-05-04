//
//  DropDiskView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "DropDiskView.h"
#import "FileHandler.h"

@implementation DropDiskView

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];    
    
    NSString *pathExtension;
    NSManagedObjectContext *managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    for (int i = 0; i < [urls count]; i++) {
    
        pathExtension = [[urls objectAtIndex:i] pathExtension];
        
        if (
            [[pathExtension lowercaseString]    isEqualTo:@"hfv"] ||
            [[pathExtension lowercaseString]    isEqualTo:@"dsk"] ||
            [[pathExtension lowercaseString]    isEqualTo:@""]
        ) {
            //[self setImage:[NSImage imageNamed:@"RomImageDocument.icns"]];
            
            FileHandler *aFileHandler = [[FileHandler alloc] init];
            //[aFileHandler readDiskFileFrom:[urls objectAtIndex:i]];
            
            NSManagedObject *managedObject = [
                NSEntityDescription
                insertNewObjectForEntityForName: @"Drives"
                         inManagedObjectContext: managedObjectContext
            ];
            
            NSString *fileName = [[urls objectAtIndex:i] lastPathComponent];
            
            /// Here we have all the fields to be inserted.
            [managedObject setValue:[urls objectAtIndex:i] forKey:@"filePath"];
            [managedObject setValue:fileName forKey:@"fileName"];

            [aFileHandler release];
                
        }
        
    }
    
    return YES;
    
}

@end
