//
//  DriveManagerWindowController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "DriveManagerWindowController.h"

@implementation DriveManagerWindowController

- (id)initWithWindow:(NSWindow *)window{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self setManagedObjectContext:[[NSApp delegate] managedObjectContext]];
    }
    
    return self;
}

- (void)windowDidLoad{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//------------------------------------------------------------------------------
// Manual getters

/*!
 * @method      managedObjectContext:
 * @abstract    Manual getter.
 */
- (NSManagedObjectContext *)managedObjectContext {
    return managedObjectContext;
}

// Manual setters

/*!
 * @method      setManagedObjectContext:
 * @abstract    Manual setter.
 */
// Manual setters

/*!
 * @method      setManagedObjectContext:
 * @abstract    Manual setter.
 */
- (void)setManagedObjectContext:(NSManagedObjectContext *)value {
    managedObjectContext = value;
}


@end
