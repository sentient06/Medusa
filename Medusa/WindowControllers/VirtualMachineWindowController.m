//
//  VirtualMachineWindowController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 10/04/2012.
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

#import "VirtualMachineWindowController.h"
#import "TableLineInformationController.h"  //Generic table lines object.
#import "PreferencesController.h"                //Object to handle coredata information.
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h" //Model for coredata entity.
#import "VirtualMachinesEntityModel.h"
#import "RomFilesEntityModel.h"
#import "RomController.h"
#import "DiskFilesEntityModel.h"
#import "AppDelegate.h"
#import "EmulatorController.h"
#import "EmulatorsEntityModel.h"
#import "EmulatorModel.h"
#import "HelpDocumentationController.h"
#import "MacintoshModelModel.h"
#import "EmulatorModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
@implementation VirtualMachineWindowController

//------------------------------------------------------------------------------
// Standard variables synthesizers.
@synthesize VMWindow;
@synthesize menuObjectsArray;
@synthesize virtualMachine;

// Bools
@synthesize enableEmulatorList;
@synthesize showGestaltList;
@synthesize sheepshaverSetup;

@synthesize allGestaltModelsArray;
@synthesize selectedGestaltModel;
@synthesize selectedEmulator;

//------------------------------------------------------------------------------
// Application synthesizers.
//@synthesize subviewsArray;
@synthesize windowTitle;
@synthesize currentPathOption;

//------------------------------------------------------------------------------
// Manual getters

#pragma mark – Manual getters

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
- (VirtualMachinesEntityModel *)virtualMachine {
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
- (void)setVirtualMachine:(VirtualMachinesEntityModel *)value {
    virtualMachine = value;
}

//------------------------------------------------------------------------------
// Methods.

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {

    [self removeObserver:self forKeyPath:@"selectedGestaltModel"];
    [self removeObserver:self forKeyPath:@"virtualMachine.romFile"];
    [self removeObserver:self forKeyPath:@"selectedEmulator"];

    [managedObjectContext processPendingChanges];
    [managedObjectContext release];
    [virtualMachine release];
    [menuObjectsArray release];
    [subviewsArray release];
    
    [gestaltModelsAvailable release];
    
    [super dealloc];
}

/**
 * This will not work for multiple windows. However, probably the class is called only once.
 */
- (void)windowWillClose:(NSNotification *)notification {
    DDLogVerbose(@"%@'s window will close", [virtualMachine name]);
    [[NSApp delegate] saveCoreData];
    

    
//    [[NSApp delegate] releaseWindowFor:[virtualMachine uniqueName]];
//    [self autorelease];
}

//------------------------------------------------------------------------------

#pragma mark – Methods

//------------------------------------------------------------------------------
// Utility methods
#pragma mark – Utility

/*!
 * @method      savePreferencesFromView:
 * @abstract    Saves all preferences in current object context.
 */
- (void)savePreferences {
    DDLogVerbose(@"Saving...");
    NSError * error;
    if (![managedObjectContext save:&error]) {
        DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
        DDLogVerbose(@"Check 'vm window controller' class. (savePreferences)");
    }
}

//------------------------------------------------------------------------------
// View change methods
#pragma mark – View change methods

- (IBAction)displayGeneralView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewConfiguration];
}

- (IBAction)displayDisksView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDrives];
}

- (IBAction)displayDisplayView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDisplay];
}

- (IBAction)displayShareView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewNetwork];
}

- (IBAction)displayAdvancedView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewAdvanced];
}

- (IBAction)displayKeyboardView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewKeyboard];
}

//------------------------------------------------------------------------------
// Interface action methods
#pragma mark – Interface action methods

- (IBAction)personalMemoryValueChanged:(id)sender {
    
    NSNumber * currentMemoryValue = [NSNumber numberWithInt:[personalMemoryField intValue]];
    
    DDLogCVerbose(@"original: %@", currentMemoryValue);
    
    NSInteger indexOfCurrentMemoryValue = [memoryDefaultValues indexOfObject:currentMemoryValue];
    
    if (NSNotFound == indexOfCurrentMemoryValue) {
//        [defaultMemorySlider setAllowsTickMarkValuesOnly:NO];
        DDLogCVerbose(@"Not found");
        
        for (int i = 0; i < [memoryDefaultValues count]; i++) {
            int intTempValue = [[memoryDefaultValues objectAtIndex:i] intValue]; //inside array
            int intMemoryValue = [currentMemoryValue intValue]; //in the field
            DDLogCVerbose(@"if (%d < %d)", intMemoryValue, intTempValue);
            if (intMemoryValue < intTempValue) {
                DDLogCVerbose(@"before %d, %u", i, i-0.5);
                [defaultMemorySlider setDoubleValue:i];
                break;
            }
        }
        
//        [defaultMemorySlider setDoubleValue:[memoryDefaultValues count]-1];
//        [defaultMemorySlider setAllowsTickMarkValuesOnly:YES];
    } else {
        [defaultMemorySlider setDoubleValue:indexOfCurrentMemoryValue];
    }
}

- (IBAction)defaultMemorySliderChanged:(id)sender {
    int current = [defaultMemorySlider intValue];
    NSNumber * selectedMemory = [memoryDefaultValues objectAtIndex:current];
    DDLogCVerbose(@"Memory chosen: %d - %@", current, selectedMemory);
    [virtualMachine setMemory:selectedMemory];
}

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
    
    NSMutableArray * selectedDrives = [
        [NSMutableArray alloc] initWithCapacity:[currentSelectedDrives count]
    ];
    //The filtered selection
    
    NSMutableSet * newDriveRelationships = [NSMutableSet set];
    //The object to update
    
    NSMutableSet * oldDriveRelationships = [NSMutableSet setWithSet:[virtualMachine disks]];
    //Warning: this is a set of relationship objects, not drives.
    //The old value updated
    
    BOOL allowed = YES;
    //Used in the filter
    
    // Filter:
    if ( [currentSelectedDrives count] > 0 ) {
        for (DiskFilesEntityModel * currentDrive in currentSelectedDrives) {
            
        //for (id object in firstSelectedDrives) {
            allowed = YES;
            
            for (RelationshipVirtualMachinesDiskFilesEntityModel * oldDriveRelationship in oldDriveRelationships) {
                
                if ([[currentDrive filePath] isEqual:[[oldDriveRelationship diskFile] filePath]]) {
                    allowed = NO;
                }

            }
            
            if (allowed) {
                [selectedDrives addObject:currentDrive];
            }
        }
    }
    
    // New updated data:
    
    long nextIndex = [oldDriveRelationships count];
    
    for (int i = 0; i < [selectedDrives count]; i++) {
        
        // Create new relationship.
        
        RelationshipVirtualMachinesDiskFilesEntityModel * newDriveRelationship = [
            NSEntityDescription
                insertNewObjectForEntityForName:@"RelationshipVirtualMachinesDiskFiles"
                         inManagedObjectContext:managedObjectContext
        ];

        [newDriveRelationship setDiskFile:[selectedDrives objectAtIndex:i]];
        [newDriveRelationship setVirtualMachine:virtualMachine];
        [newDriveRelationship setPositionIndex:[NSNumber numberWithLong:nextIndex + i]];
        
        [newDriveRelationships addObject:newDriveRelationship];
        
    }

    //Finally:
    
    [newDriveRelationships unionSet:oldDriveRelationships];
    [virtualMachine setValue:newDriveRelationships forKey:@"disks"]; //Re-set the value.
    
    [self resetDriveOrder];
    
    [selectedDrives release];

}

- (void)updateEmulatorFromList:(NSNumber *)listIndex {
    DDLogVerbose(@"updated emulator: %@", listIndex);
    // Handles empty emulator:
    if ([listIndex intValue] == -1) return;
    // Handles selection from list:
    id obj = [[self managedObjectContext] objectWithID:[emulatorsAvailable objectForKey:listIndex]];
    [virtualMachine setEmulator:obj];
    [[NSApp delegate] saveCoreData];
}

- (void)updateMacModelFromList:(NSNumber *)listIndex {
    
    DDLogVerbose(@"updated gestalt model: %@", listIndex);
    
    BOOL useSimpleModel = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"useSimpleModel"
    ];
    
    // The first block is when there are a couple of radio buttons for Mac IIci and Q900.
    if (useSimpleModel) {
        [virtualMachine setMacModel:listIndex];
    } else {
        // The gestalt controller is an array and each item is a dictionary.
        // This means that we must fetch the item at a given index and then match the index of the dictionary.
        
        int i = 0;
        long max = [listIndex longValue];
        long selectedItem = 0;
        
        NSArray * keys = [gestaltModelsAvailable allKeys];
        NSArray * sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
        for (NSString * dKey in sortedKeys) {
            if (max == i) {
                selectedItem = [dKey longLongValue];
                break;
            }
            i++;
        }
        [virtualMachine setMacModel:[NSNumber numberWithLongLong:selectedItem]];
    }
    [[NSApp delegate] saveCoreData];
}

//// comment this
- (void)resetDriveOrder {
    DDLogCVerbose(@"Reseting drives order");
    NSArray * allDrives = [usedDisksController arrangedObjects];

    // Iterate through all drives and set them to i.
    for (int i = 0; i < [allDrives count]; i++) {
        [[allDrives objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"positionIndex"];
    }

    [self savePreferences];
    
}

/*!
 * @method      deleteUsedDrive:
 * @abstract    Deletes a drive.
 * @discussion  Iterates through all selected drives of the current VM
 *              and delete them.
 */
- (IBAction)deleteUsedDrive:(id)sender {
    
    NSArray * selectedDrives = [usedDisksController selectedObjects]; //Selected drives
    
    // Iterate through all drives and set to NO.
    for (int i = 0; i < [selectedDrives count]; i++) {
        [managedObjectContext deleteObject:[selectedDrives objectAtIndex:i]];
    }
    [self resetDriveOrder];
    
    [self savePreferences];
    
}

//------------------------------------------------------------------------------
// Sharing

/*!
 * @method      changeSharedFolderPath:
 * @abstract    Changes share folder options.
 * @discussion  Checks the value of the NSMatrix in the currentPathOption
 *              variable, saves new data in the datamodel and changes interface
 *              details accordinly.
 */
- (IBAction)changeShareType:(id)sender {
    
    if ( currentPathOption == useStandardPathOption ) {          
        [openSharePathButton setEnabled:NO];
        [sharePathLabel setStringValue:
            [
                [NSUserDefaults standardUserDefaults] stringForKey:@"StandardSharePath"
            ]
        ];
        
        [virtualMachine setShareEnabled:[NSNumber numberWithBool:YES]];
        [virtualMachine setUseDefaultShare:[NSNumber numberWithBool:YES]];
        
    }else
        if ( currentPathOption == usePersonalPathOption ) {
        [openSharePathButton setEnabled:YES];
        if ([virtualMachine sharedFolder] == nil ) {
            [sharePathLabel setStringValue:@"Path not defined"];
        }else{
            [sharePathLabel setStringValue:
                [virtualMachine sharedFolder]
            ];
        }
        
        [virtualMachine setShareEnabled:[NSNumber numberWithBool:YES]];
        [virtualMachine setUseDefaultShare:[NSNumber numberWithBool:NO]];
        
    }else{
        [openSharePathButton setEnabled:NO];
        [sharePathLabel setStringValue:@"None"];

        [virtualMachine setShareEnabled:[NSNumber numberWithBool:NO]];
        [virtualMachine setUseDefaultShare:[NSNumber numberWithBool:NO]];
        
    }
    
    [self savePreferences];
    
}

/*!
 * @method      savePreferencesFromView:
 * @abstract    Saves all preferences in current object context.
 */
- (IBAction)savePreferencesFromView:(id)sender {
    [self savePreferences];
}

- (IBAction)displayHelpForAdvancedView:(id)sender {
    [HelpDocumentationController openHelpPage:@"01.html"];
}

- (IBAction)logVM:(id)sender {
    DDLogVerbose(@"%@", virtualMachine);
}

//------------------------------------------------------------------------------
// Open file methods
#pragma mark – Open file methods

/*!
 * @method      openSharePath:
 * @abstract    Displays open panel to select the folder to be shared.
 * @discussion  Maybe I should replace it with a shared folder preference?
 */
- (IBAction)openSharePath:(id)sender {
        
    NSArray * selectedFiles = [[[NSArray alloc] init] autorelease];
    
    NSOpenPanel * openDialog = [NSOpenPanel openPanel]; //File open dialog class.
    
    //Dialog options:
    [openDialog setCanChooseFiles:NO];
    [openDialog setCanChooseDirectories:YES];
    [openDialog setCanCreateDirectories:YES];
    [openDialog setAllowsMultipleSelection:NO];
    
    //Display it and trace OK button:
    if ([openDialog runModal] == NSOKButton) {
        selectedFiles = [openDialog URLs];        
    }
    
    if ([selectedFiles count] == 1) {
        DDLogVerbose(@"%@", selectedFiles);
        [virtualMachine setSharedFolder: [[selectedFiles objectAtIndex:0] path]];
    }
    
    DDLogVerbose(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
        DDLogVerbose(@"Check 'vm window controller' class; openSharePath");
    }
    
    [sharePathLabel setStringValue:
        [[selectedFiles objectAtIndex:0] path]
    ];
    
}

/*!
 * @method      openRunPath:
 * @abstract    Displays open panel to select the ROM image to be used.
 */
- (IBAction)openRomPath:(id)sender {
    
    NSOpenPanel   * openDialog     = [NSOpenPanel openPanel]; //File open dialog class.
    RomController * RomModelObject = [[RomController alloc] init];
    
    //Dialog options:
    [openDialog setCanChooseFiles:YES];
    [openDialog setCanChooseDirectories:NO];
    [openDialog setCanCreateDirectories:NO];
    [openDialog setAllowsMultipleSelection:NO];
    [openDialog setAllowedFileTypes: [NSArray arrayWithObjects:@"rom", nil]];

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Displays open dialog:    
    [openDialog beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray * selectedFiles = [[
                [NSArray alloc] initWithArray:[openDialog URLs]
            ] autorelease];
            if ([selectedFiles count] == 1) {
                DDLogVerbose(@"Selected files: %@", selectedFiles);
                RomFilesEntityModel * currentRom = [
                    RomModelObject
                    parseSingleRomFileAndSave:[[selectedFiles objectAtIndex:0] path]
                              inObjectContext:managedObjectContext
                ];
                [virtualMachine setRomFile:currentRom];
            }
        }
    }];
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    [RomModelObject release];
    
}

- (IBAction)openEmulatorPath:(id)sender {

    NSOpenPanel   * openDialog = [NSOpenPanel openPanel]; //File open dialog class.
    EmulatorController * emulatorsModelObject = [[EmulatorController alloc] init];
    
    //Dialog options:
    [openDialog setCanChooseFiles:YES];
    [openDialog setCanChooseDirectories:NO];
    [openDialog setCanCreateDirectories:NO];
    [openDialog setAllowsMultipleSelection:NO];
    [openDialog setAllowedFileTypes: [NSArray arrayWithObjects:@"public.executable", nil]];
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Displays open dialog:    
    [openDialog beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray * selectedFiles = [[
                [NSArray alloc] initWithArray:[openDialog URLs]
            ] autorelease];
            if ([selectedFiles count] == 1) {
                DDLogVerbose(@"Selected files: %@", selectedFiles);
                EmulatorsEntityModel * addedEmulator = [emulatorsModelObject parseEmulator:[[selectedFiles objectAtIndex:0] path]];
                if (addedEmulator != nil) {
                    [virtualMachine setEmulator:addedEmulator];
                }
            }
        }
    }];
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    [emulatorsModelObject release];
     
}


//------------------------------------------------------------------------------
// Observers
#pragma mark – Observers

/*!
 * @method      observeValueForKeyPath:
 *              ofObject:
 *              change:
 *              context:
 * @abstract    Observer method.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    DDLogVerbose(@"-----------------------------");
    DDLogVerbose(@"Observed keyPath: %@", keyPath);
    DDLogVerbose(@"-----------------------------");
    
    if ([keyPath isEqualToString:@"selectedGestaltModel"]) {
        [self updateMacModelFromList:[object valueForKeyPath:keyPath]];
    }
    
    if ([keyPath isEqualToString:@"selectedEmulator"]) {
        [self updateEmulatorFromList:[object valueForKeyPath:keyPath]];
    }
    
    if ([keyPath isEqualToString:@"virtualMachine.romFile"]) {
        if ([virtualMachine romFile] == nil) return;
        [self repopulateEmulatorList];
        [self repopulateGestaltList];
        [self updateEmulatorFamily];
        [self updateProcessor];
        [[NSApp delegate] saveCoreData];
    }
    
}

//------------------------------------------------------------------------------
// Workflow Methods

/*!
 * @method      repopulateEmulatorList
 * @abstract    Populates the list of allowed emulators and selects current one.
 */
- (void)repopulateEmulatorList {
    DDLogVerbose(@"Repopulating emulator list");
    
    // Fetches all emulators for this rom:
    NSArray * emulators = [
        EmulatorModel fetchAllAvailableEmulatorsForEmulatorType:[
            [[virtualMachine romFile] emulatorType] intValue
        ]
    ];
    
    // Clear lists of emulators:
    [[availableEmulatorsController content] removeAllObjects];
    [emulatorsAvailable release];
    emulatorsAvailable = [[NSMutableDictionary alloc] init];
    
    if ([emulators count] == 0) {
        DDLogVerbose(@"no emulators found");
        NSDictionary * thisEmulator = [
            [NSDictionary alloc] initWithObjectsAndKeys:
            nil, @"name"
            , nil, @"key"
            , nil
        ];
        [availableEmulatorsController addObject:thisEmulator];
        [thisEmulator release];
        [self setSelectedEmulator:[NSNumber numberWithInt:-1]];
        [self setEnableEmulatorList: NO];
        [virtualMachine setEmulator:nil];
        return;
    }
    
    // Iterates all emulators available:
    
    int counter = 0;
    int emulatorInUse = -1;
    
    for (EmulatorsEntityModel * emulator in emulators) {

        NSDictionary * thisEmulator = [
            [NSDictionary alloc] initWithObjectsAndKeys:
            [emulator name], @"name"
            , [NSNumber numberWithInt:counter], @"key"
            , nil
        ];
        
        // Add emulator to lists:
        [availableEmulatorsController addObject:thisEmulator];
        [emulatorsAvailable setObject:[emulator objectID] forKey:[NSNumber numberWithInt:counter]];

        // Select matched emulator:
        if ([[emulator objectID] isEqualTo:[[virtualMachine emulator] objectID]]) {
            emulatorInUse = counter;
        }

        [thisEmulator release];
        counter++;
    }

    // Select emulator in use or the first one:
    if (emulatorInUse > -1) {
        [self setSelectedEmulator:[NSNumber numberWithInt:emulatorInUse]];
    } else {
        DDLogWarn(@"Emulator is not in the list, selecting first item");
        [self updateEmulatorFromList:[NSNumber numberWithInt:0]];
        [self setSelectedEmulator:[NSNumber numberWithInt:0]];
    }

    [self setEnableEmulatorList:YES];
    DDLogVerbose(@"selectedEmulator: %@", selectedEmulator);
    DDLogVerbose(@"emulatorsAvailable: %@", emulatorsAvailable);
    
}

/*!
 * @method      repopulateGestaltList
 * @abstract    Populates the list of Macintosh models and selects current one.
 */
- (void)repopulateGestaltList {

    DDLogVerbose(@"Repopulating gestalt list");
    
    int emulatorType = [[[virtualMachine romFile] emulatorType] intValue];

    NSDictionary * allModels = [
        [NSDictionary alloc] initWithDictionary:
            [MacintoshModelModel
                fetchAllAvailableModelsForChecksum:[[virtualMachine romFile] checksum]
                                       andEmulator:emulatorType
            ]
    ];

    NSArray * sortKeys = [[allModels allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 intValue] > [obj2 intValue])
            return (NSComparisonResult)NSOrderedDescending;
        if ([obj1 intValue] < [obj2 intValue])
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];


    [[availableGestaltModelsController content] removeAllObjects];
    
    int counter = 0;
    BOOL selectedInThisList = NO;
    NSNumber * selectedModel = [virtualMachine macModel];
    
    for (NSNumber * key in sortKeys) {
        NSDictionary * thisModel = [
            [NSDictionary alloc] initWithObjectsAndKeys:
                [allModels objectForKey:key], @"name"
              , key, @"key"
              , nil
        ];
        [availableGestaltModelsController addObject:thisModel];
        DDLogVerbose(@"%@ - %@ - %@", key, [virtualMachine macModel], [key isEqualToNumber:[virtualMachine macModel]] ? @"True" : @"False");
        if ([key isEqualToNumber:selectedModel]) {
            [self setSelectedGestaltModel:[NSNumber numberWithInt:counter]];
            selectedInThisList = YES;
        }
        [thisModel release];
        counter++;
    }
    
    // The order here is important because 'updateMacModelFromList' uses 'gestaltModelsAvailable'!!
    
    [gestaltModelsAvailable release];
    gestaltModelsAvailable = [[NSMutableDictionary alloc] initWithDictionary:allModels];
    
    
    // If simple model selection is chosen, it only shows when emulator is from Basilisk family.
    // Else, we should see the drop-down list.
    
    if (selectedInThisList == NO) {
        DDLogWarn(@"Mac model is not in the list, selecting first item");
        [self setSelectedGestaltModel:[NSNumber numberWithInt:0]];
        [self updateMacModelFromList:[NSNumber numberWithInt:0]];
    }
    
    [allModels release];
}

- (void)updateEmulatorFamily {
    int family = [EmulatorModel familyFromEmulatorType:[[[virtualMachine romFile] emulatorType] intValue]];
    if (family == sheepshaverFamily) {
        [self setSheepshaverSetup:YES];
    } else {
        [self setSheepshaverSetup:NO];
    }
}

- (void)updateProcessor {
    int family = [EmulatorModel familyFromEmulatorType:[[[virtualMachine romFile] emulatorType] intValue]];
    int processor = [[virtualMachine processorType] intValue];
    if (family == sheepshaverFamily) {
        [virtualMachine setProcessorType:[NSNumber numberWithInt:PPC7400]];
    } else {
        if (processor == PPC7400)
            [virtualMachine setProcessorType:[NSNumber numberWithInt:MC68040]];
    }
}

- (void)updateWindow {
    DDLogVerbose(@"Update window");
    [self repopulateGestaltList];
}

//------------------------------------------------------------------------------
// Init methods
#pragma mark – Init methods

/*!
 * @method      initWithVirtualMachine:inManagedObjectContext:
 * @abstract    Init method.
 */
- (id)initWithVirtualMachine:(VirtualMachinesEntityModel *)aVirtualMachine
      inManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
    
    //----------------------------------------------------------
    //VM details
    DDLogVerbose(@"%@", aVirtualMachine);
    
    //----------------------------------------------------------
    //Interface view
    
    self = [super initWithWindowNibName:@"VirtualMachineWindow"];
    
    if (self) {
    
        [self setManagedObjectContext:theManagedObjectContext];
        [self setVirtualMachine:aVirtualMachine];
        [self setWindowTitle:[NSString stringWithFormat:@"%@ Settings", [virtualMachine name]]];

        //------------------------------------------------------
        //Interface subviews
        
        // -- Share tab
        
        // Handle the status of the open path button in the share area:
        
        BOOL enabledShare = [[virtualMachine shareEnabled] boolValue] == YES;
        BOOL shareDefault = [[virtualMachine useDefaultShare] boolValue] == YES;
        
        if ( enabledShare &  shareDefault ) {          
            currentPathOption = useStandardPathOption;
        } else if ( enabledShare & !shareDefault ) {
            currentPathOption = usePersonalPathOption;
        } else if ( !enabledShare & !shareDefault ) {
            currentPathOption = useNoSharedPathOption;
        }
    }
    
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
//        [[NSNotificationCenter defaultCenter]
//         addObserver:self
//         selector:@selector(windowWillClose:)
//         name:NSWindowWillCloseNotification
//         object:window];
        DDLogVerbose(@"new vm controller init");

    }
    
    return self;
}

/*!
 * @method      windowDidLoad:
 * @abstract    Sent after the window owned by the receiver has been loaded.
 * @discussion  Refer to official documentation.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    //----------------------------------------------------------
    //Interface view
    
    [placeholderView addSubview:subViewConfiguration];
    
    //----------------------------------------------------------
    //Interface subviews
    
    // -- Share tab
    
    //Handle the status of the open path button in the share area:
    
    BOOL enabledShare = [[virtualMachine shareEnabled]    boolValue] == YES;
    BOOL shareDefault = [[virtualMachine useDefaultShare] boolValue] == YES;
    
    if ( enabledShare &  shareDefault ) {          
        [openSharePathButton setEnabled:NO];
        [sharePathLabel setStringValue:
            [ [NSUserDefaults standardUserDefaults] stringForKey:@"StandardSharePath" ]
        ];
    } else if ( enabledShare & !shareDefault ) {
        [openSharePathButton setEnabled:YES];
        [sharePathLabel setStringValue:
            [virtualMachine sharedFolder]
        ];
    } else if ( !enabledShare & !shareDefault ) {
        [openSharePathButton setEnabled:NO];
        [sharePathLabel setStringValue:@"None"];
    }

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [settingsToolbar setSelectedItemIdentifier:@"generalButton"];
    
}

-(void)awakeFromNib {
    [super awakeFromNib];
    NSSortDescriptor * mySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"positionIndex" ascending:YES];
    [usedDisksController setSortDescriptors:[NSArray arrayWithObject:mySortDescriptor]];
    [mySortDescriptor release]; 
    
    memoryDefaultValues = [
        [NSArray alloc] initWithObjects:
          [NSNumber numberWithInt:8]
        , [NSNumber numberWithInt:16]
        , [NSNumber numberWithInt:32]
        , [NSNumber numberWithInt:64]
        , [NSNumber numberWithInt:128]
        , [NSNumber numberWithInt:256]
        , [NSNumber numberWithInt:512]
        , [NSNumber numberWithInt:1024]
        , [NSNumber numberWithInt:2048]
        , nil
    ];
    
    [defaultMemorySlider setNumberOfTickMarks:[memoryDefaultValues count]];
    [defaultMemorySlider setMinValue:0];
    [defaultMemorySlider setMaxValue:[memoryDefaultValues count]-1];
    [defaultMemorySlider setAllowsTickMarkValuesOnly:YES];
    
    
    if ([virtualMachine romFile]) {
        [self repopulateEmulatorList];
        [self repopulateGestaltList];
        [self updateEmulatorFamily];
    }

//    int emulatorType = [[[virtualMachine romFile] emulatorType] intValue];
    
//    if (emulatorType) {
//        [self repopulateGestaltList];
//    }
    
    [ self addObserver:self
            forKeyPath:@"virtualMachine.romFile"
               options:NSKeyValueObservingOptionNew
               context:nil
    ];

    [ self addObserver:self
            forKeyPath:@"selectedEmulator"
               options:NSKeyValueObservingOptionNew
               context:nil
    ];
    
    [ self addObserver:self
            forKeyPath:@"selectedGestaltModel"
               options:NSKeyValueObservingOptionNew
               context:nil
    ];

//{STR_JIT_CACHE_SIZE_2MB_LAB, "2048"},
//{STR_JIT_CACHE_SIZE_4MB_LAB, "4096"},
//{STR_JIT_CACHE_SIZE_8MB_LAB, "8192"},
//{STR_JIT_CACHE_SIZE_16MB_LAB, "16384"},
    
    [self personalMemoryValueChanged:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(windowWillClose:)
            name:NSWindowWillCloseNotification
          object:self.window
    ];
    
}

@end
