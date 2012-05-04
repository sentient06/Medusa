//
//  VirtualMachineWindowController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 10/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------

#import "VirtualMachineWindowController.h"
#import "TableLineInformationController.h" //Generic table lines object.

//------------------------------------------------------------------------------
@implementation VirtualMachineWindowController

//------------------------------------------------------------------------------
// Standard variables synthesizers.
@synthesize menuObjectsArray;

//------------------------------------------------------------------------------
// Application synthesizers.
//@synthesize subviewsArray;

//------------------------------------------------------------------------------
// Manual getters

/*!
 * @method      managedObjectContext:
 * @abstract    Manual getter.
 */
- (NSManagedObjectContext *)managedObjectContext {
    return managedObjectContext;
}

/*!
 * @method      virtualMachine:
 * @abstract    Manual getter.
 */
- (NSManagedObject *)virtualMachine {
    return virtualMachine;
}

// Manual setters

/*!
 * @method      setManagedObjectContext:
 * @abstract    Manual setter.
 */
- (void)setManagedObjectContext:(NSManagedObjectContext *)value {
    managedObjectContext = value;
}

/*!
 * @method      setVirtualMachine:
 * @abstract    Manual setter.
 */
- (void)setVirtualMachine:(NSManagedObject *)value {
    virtualMachine = value;
}



// Init methods

/*!
 * @method      initWithVirtualMachine:inManagedObjectContext:
 * @abstract    Init method.
 */
- (id)initWithVirtualMachine:(NSManagedObject *)aVirtualMachine
      inManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
    
    //----------------------------------------------------------
    //VM details
    NSLog(@"%@", aVirtualMachine);
    
    
    //----------------------------------------------------------
    //Interface
    
    self = [super initWithWindowNibName:@"VirtualMachineWindow"];
    
    if (self) {
        
        TableLineInformationController *information = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Information"
                  andIcon:@"Info.icns"
        ];

        TableLineInformationController *configuration = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Configuration"
                  andIcon:@"RomFile.icns"
        ];
        
        TableLineInformationController *display = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Display"
                  andIcon:@"Display.icns"
        ];

        TableLineInformationController *drives = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Drives"
                  andIcon:@"Drive.icns"
        ];
/*
        TableLineInformationController *share = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Sharing"
                  andIcon:@"Shared.icns"
        ];

        TableLineInformationController *advanced = [
            [TableLineInformationController alloc]                
            initWithTitle:@"Advanced"
                  andIcon:@"Configuration.icns"
        ];
*/
        
        menuObjectsArray = [
            [NSMutableArray alloc]
            initWithObjects:information, configuration, display, drives, nil
        ];
        
//        subviewsArray = [
//            [NSMutableArray alloc]
//            initWithObjects:
//            subViewConfiguration, subViewDisplay, subViewDrives, subViewSharing, subViewAdvanced, nil
//        ];
        
        NSLog(@"%@", subviewsArray);
/*        [advanced release];
        [share release];
*/        [drives release];
        [display release];
        [configuration release];
    }
    
    [self setManagedObjectContext:theManagedObjectContext];
    [self setVirtualMachine:aVirtualMachine];
    return self;

}

/*!
 * @method      initWithWindow:
 * @abstract    Standard init method.
 */
- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//------------------------------------------------------------------------------

/*!
 * @method      changeRightView:
 * @abstract    Changes the right pane according to the selected item in the
 *              left pane menu.
 * @discussion  Oh man...
 */
- (IBAction)changeRightView:(id)sender {
    
}

- (IBAction)traceTableViewClick:(id)sender {
    
    
    
//    NSLog(@"%d", [detailsTree selectedRow] );

    [[[rightView subviews] objectAtIndex:0] removeFromSuperview];
    
    switch ([detailsTree selectedRow]) {
        default:
        case 0:
            [rightView addSubview: subViewInformation];
            break;

        case 1:
            [rightView addSubview: subViewConfiguration];
            break;
            
        case 2:
            [rightView addSubview: subViewDisplay];
            break;
            
        case 3:
            [rightView addSubview: subViewDrives];
            break;
            
        case 4:
            [rightView addSubview: subViewSharing];
            break;
            
        case 5:
            [rightView addSubview: subViewAdvanced];
            break;
    }
    
    //[[[rightView subviews] objectAtIndex:0] removeFromSuperview];
    //[rightView addSubview: [subviewsArray objectAtIndex:[detailsTree selectedRow]]];
    //[[splitRightView subviews] objectAtIndex:0] removeFromSuperview];
    
}


//------------------------------------------------------------------------------
/*!
 * @method      useSelectedDisks:
 * @abstract    Checks the selected disks in the drives list and adds to the vm.
 * @discussion  This is the action of the button with the same name in the
 *              drives subview in the vm interface.
 */
- (IBAction)useSelectedDisks:(id)sender {
    
}

/*!
 * @method      aa
 * @abstract    aa
 * @discussion  aa
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [rightView addSubview:subViewInformation];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
