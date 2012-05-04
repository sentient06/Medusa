//
//  VirtualMachineWindowController.h
//  Medusa
//
//  Created by Giancarlo Mariot on 10/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

/*!
 * @class       VirtualMachineWindowController:
 * @abstract    Responsible for the iTunes-like window.
 * @discussion  This is the class that takes care of the virtual machine's
 *              information as seen and presented to the user.
 *
 * @var     managedObjectContext    The coredata object.
 * @var     virtualMachine          The coredata entity VM object.
 * @var     objectsArray            The options in the left pane.s
 */
@interface VirtualMachineWindowController : NSWindowController {
    //Standard variables
    NSManagedObjectContext  *managedObjectContext;
    NSManagedObject         *virtualMachine;
    
    NSMutableArray          *menuObjectsArray;
    NSMutableArray          *subviewsArray;
    
    //Interface objects
    IBOutlet NSTableView    *detailsTree;
    IBOutlet NSView         *rightView;
    IBOutlet NSView         *subViewInformation;
    IBOutlet NSView         *subViewConfiguration;
    IBOutlet NSView         *subViewDisplay;
    IBOutlet NSView         *subViewDrives;
    IBOutlet NSView         *subViewSharing;
    IBOutlet NSView         *subViewAdvanced;
    
    IBOutlet NSArrayController   *availableDisksController;
//    NSArray  *subViews;
}
//------------------------------------------------------------------------------
// Standard variables properties.
@property (copy) NSMutableArray *menuObjectsArray;

//------------------------------------------------------------------------------
// Application properties.
//@property (nonatomic, retain) IBOutlet NSView *subViewConfiguration;
//@property (nonatomic, retain) IBOutlet NSView *subViewDisplay;
//@property (nonatomic, retain) IBOutletCollection(NSView) NSArray *subviewsArray;

//------------------------------------------------------------------------------
// Manual getters
- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObject *)virtualMachine;

// Manual setters
- (void)setManagedObjectContext:(NSManagedObjectContext *)value;
- (void)setVirtualMachine:(NSManagedObject *)value;

// Init methods
- (id)initWithVirtualMachine:(NSManagedObject *)aVirtualMachine
      inManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;

//------------------------------------------------------------------------------
// Interface Methods

// View actions
- (IBAction)changeRightView:(id)sender;
- (IBAction)traceTableViewClick:(id)sender;
- (IBAction)useSelectedDisks:(id)sender;

@end
