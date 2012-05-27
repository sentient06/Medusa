//
//  DropDiskView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

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
            [[pathExtension lowercaseString]    isEqualTo:@"hfv"] ||
            [[pathExtension lowercaseString]    isEqualTo:@"dsk"] ||
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
