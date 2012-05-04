//
//  DriveManagerWindowController.h
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DropView;

@interface DriveManagerWindowController : NSWindowController {
    
    NSManagedObjectContext  *managedObjectContext;
    
    IBOutlet DropView *dropFileContainer;    
}

//------------------------------------------------------------------------------
// Manual setters
- (NSManagedObjectContext *)managedObjectContext;

// Manual getters
- (void)setManagedObjectContext:(NSManagedObjectContext *)value;

@end
