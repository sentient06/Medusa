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
#import "PreferencesModel.h" //Object to handle coredata information.
#import "RelationshipVirtualMachinesDrivesModel.h" //Model for coredata entity.
#import "VirtualMachinesModel.h"
#import "RomFilesModel.h"
#import "DrivesModel.h"

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
- (VirtualMachinesModel *)virtualMachine {
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
- (void)setVirtualMachine:(VirtualMachinesModel *)value {
    virtualMachine = value;
}

//------------------------------------------------------------------------------
// Methods.

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [managedObjectContext release];
    [virtualMachine release];
    [menuObjectsArray release];
    [subviewsArray release];
    
    [super dealloc];
}

// Init methods

/*!
 * @method      initWithVirtualMachine:inManagedObjectContext:
 * @abstract    Init method.
 */
- (id)initWithVirtualMachine:(VirtualMachinesModel *)aVirtualMachine
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
        
        //NSLog(@"%@", subviewsArray);
/*        [advanced release];
        [share release];
*/        [drives release];
        [display release];
        [configuration release];
        [information release];
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
    
    /// Must move everything here to a new coredata class!
    
    NSArray * currentSelectedDrives = [availableDisksController selectedObjects];
    //The current selection
    
    NSMutableArray *selectedDrives = [
        [NSMutableArray alloc] initWithCapacity:[currentSelectedDrives count]
    ];
    //The filtered selection
    
    NSMutableSet *newDriveRelationships = [NSMutableSet set];
    //The object to update
    
    NSMutableSet *oldDriveRelationships = [NSMutableSet setWithSet:[virtualMachine drives]];
    //Warning: this is a set of relationship objects, not drives.
    //The old value updated
    
    BOOL allowed = YES;
    //Used in the filter
    
    // Filter:
    if ( [currentSelectedDrives count] > 0 ) {
        for (DrivesModel * currentDrive in currentSelectedDrives) {
            
        //for (id object in firstSelectedDrives) {
            allowed = YES;
            
            for (RelationshipVirtualMachinesDrivesModel * oldDriveRelationship in oldDriveRelationships) {
                
                if ([[currentDrive filePath] isEqual:[[oldDriveRelationship drive] filePath]]) {
                    allowed = NO;
                }

            }
            
            if (allowed) {
                [selectedDrives addObject:currentDrive];
            }
        }
    }
    
    // New updated data:
    
    for (int i = 0; i < [selectedDrives count]; i++) {
        
        // Create new relationship.
        
        RelationshipVirtualMachinesDrivesModel *newDriveRelationship = [
            NSEntityDescription
                insertNewObjectForEntityForName:@"RelationshipVirtualMachinesDrives"
                         inManagedObjectContext:managedObjectContext
        ];

        [newDriveRelationship setDrive:[selectedDrives objectAtIndex:i]];
        [newDriveRelationship setVirtualMachine:virtualMachine];
        
        [newDriveRelationships addObject:newDriveRelationship];
        
    }

    //Finally:
    
    [newDriveRelationships unionSet:oldDriveRelationships];
    [virtualMachine setValue:newDriveRelationships forKey:@"drives"]; //Re-set the value.
    
    NSLog(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSLog(@"Check 'vm window controller' class.");
    }
    
    [selectedDrives release];

}

/*!
 * @method      makeDriveBootable:
 * @abstract    Set a drive as boot drive.
 * @discussion  Iterates through all drives of the current VM and set all of
 *              them to not-bootable, then it sets the first selected to
 *              bootable.
 */
- (IBAction)makeDriveBootable:(id)sender {
    
    NSArray *selectedDrives = [usedDisksController selectedObjects]; //Selected drives
    NSArray *allDrives = [usedDisksController arrangedObjects];      //All drives
    
    // Iterate through all drives and set to NO.
    for (int i = 0; i < [allDrives count]; i++) {
        [[allDrives objectAtIndex:i] setValue:[NSNumber numberWithBool:NO] forKey:@"bootable"];
    }
    
    // Set first selected to YES.
    [[selectedDrives objectAtIndex:0] setValue:[NSNumber numberWithBool:YES] forKey:@"bootable"];
    
    NSLog(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSLog(@"Check 'vm window controller' class.");
    }
    
}

/*!
 * @method      deleteUsedDrive:
 * @abstract    Deletes a drive.
 * @discussion  Iterates through all selected drives of the current VM
 *              and delete them.
 */
- (IBAction)deleteUsedDrive:(id)sender {
    
    NSArray *selectedDrives = [usedDisksController selectedObjects]; //Selected drives
    
    // Iterate through all drives and set to NO.
    for (int i = 0; i < [selectedDrives count]; i++) {
        [managedObjectContext deleteObject:[selectedDrives objectAtIndex:i]];
    }
    
    NSLog(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSLog(@"Check 'vm window controller' class.");
    }
    
}

/*!
 * @method      aa
 * @abstract    aa
 * @discussion  aa
 */
- (IBAction)run:(id)sender {
    
    PreferencesModel *preferences = [[PreferencesModel alloc] init];
    NSArray *data = [preferences getVirtualMachineData:virtualMachine];
    NSURL * emulatorPath; // = [[NSURL alloc] init];
    NSMutableString * preferencesFilePath; // = [[NSMutableString alloc] init];

    if ([[[virtualMachine model] emulator] isEqualTo:@"Basilisk"]) {
        preferencesFilePath = [NSMutableString stringWithFormat:@"%@/%@", NSHomeDirectory(), @".basilisk_ii_prefs"];
        emulatorPath = [[NSUserDefaults standardUserDefaults] URLForKey: @"BasiliskPath"];
    }else{
        preferencesFilePath = [NSMutableString stringWithFormat:@"%@/%@", NSHomeDirectory(), @".sheepshaver_prefs"];
        emulatorPath = [[NSUserDefaults standardUserDefaults] URLForKey:@"SheepshaverPath"];
    }
        
    NSLog(@"%@", preferencesFilePath);
    NSLog(@"%@", emulatorPath);
    
    [preferences savePreferencesFile:data ForFile:preferencesFilePath];
    [[NSWorkspace sharedWorkspace] openURL:emulatorPath];
    
//    [preferencesFilePath release];
//    [emulatorPath release];
    [preferences release];

}

/*
/ *!
 * @method      aa
 * @abstract    aa
 * @discussion  aa
 * /
- (void)savePrefsFile
*/

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
