//
//  AppDelegate.m
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

//define VERSION

#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Windows
#import "VirtualMachineWindowController.h"  //VM Window
#import "AssetsWindowController.h"          //Assets Window
#import "PreferencesWindowController.h"     //Preferences Window

// Transformers
#import "IconValueTransformer.h"            //Transforms a coredata integer in an icon

// Models:
#import "VirtualMachinesEntityModel.h"
#import "DiskFilesEntityModel.h"

// Controllers
#import "PreferencesController.h"
#import "VirtualMachineController.h"
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h"
#import "FileManager.h"

// Enums and structs
#import "EmulatorsEntityModel.h"

// Classes that make migrations less painful.
#import "MigrationAssistant.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_INFO;
//------------------------------------------------------------------------------

@implementation AppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

//------------------------------------------------------------------------------
// Methods.

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    [virtualMachineTasks release];
    [windowsForVirtualMachines release];
    [super dealloc];
}

//------------------------------------------------------------------------------
// Application methods.

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Virtual machine sheets

#pragma mark – Sheet actions

/*!
 * @method      showNewMachineView:
 * @abstract    Displays the new VM sheet.
 */
- (IBAction)showNewMachineView:(id)sender {

    if ([sender tag] == 1) {
        newVirtualMachineIdentifier = addNew;
    } else if ([sender tag] == 2) {
        newVirtualMachineIdentifier = duplicate;
    } else if ([sender tag] == 3) {
        newVirtualMachineIdentifier = importBasilisk;
    } else if ([sender tag] == 4) {
        newVirtualMachineIdentifier = importSheepShaver;
    } else {
        newVirtualMachineIdentifier = newVMError;
    }
    
    switch (newVirtualMachineIdentifier) {
        case addNew:
            [newMachineDescriptionLabel setStringValue:@"Create new virtual machine:"];
            break;
        case duplicate:
            [newMachineDescriptionLabel setStringValue:@"Duplicate virtual machine:"];
            break;
        case importBasilisk:
            [newMachineDescriptionLabel setStringValue:@"Import Basilisk II's preferences into new virtual machine:"];
            break;
        case importSheepShaver:
            [newMachineDescriptionLabel setStringValue:@"Import SheepShaver's preferences into new virtual machine:"];
            break;
        default:
            break;
    }

    [ NSApp
            beginSheet: newMachineView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      showDeleteMachineView:
 * @abstract    Displays the delete VM sheet.
 */
- (IBAction)showDeleteMachineView:(id)sender {
    [ NSApp
            beginSheet: deleteMachineView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      showErrorSheetView:
 * @abstract    Displays the error sheet.
 */
- (IBAction)showErrorSheetView:(id)sender {
    [ NSApp
            beginSheet: errorSheetView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endNewMachineView:(id)sender {
    [newMachineErrorLabel setHidden:YES];
    [newMachineNameField setStringValue:@""];
    [NSApp endSheet:newMachineView];
    [newMachineView orderOut:sender];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endDeleteMachineView:(id)sender {
    [NSApp endSheet:deleteMachineView];
    [deleteMachineView orderOut:sender];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endErrorSheetView:(id)sender {
    [NSApp endSheet:errorSheetView];
    [errorSheetView orderOut:sender];
}

/*!
 * @method      saveNewVirtualMachine:
 * @abstract    Saves the new virtual machine created by the user to the
 *              coredata.
 * @discussion  This method is sort of messed. There is a need to check
 *              the existence of the vm model before proceeding and this
 *              leads to a whole new world of lines that I suppose are
 *              not needed. Remember to refactor in the near future.
 */
- (IBAction)saveNewVirtualMachine:(id)sender {
    
    // Parses name:
    NSString * newMachineName = [[NSString alloc] initWithString:[newMachineNameField stringValue]];

    if ([newMachineName length] == 0) {
        DDLogVerbose(@"VM name is empty.");
        [newMachineErrorLabel setStringValue:@"Name cannot be empty."];
        [newMachineErrorLabel setHidden:NO];
        [newMachineName release];
        return;
    }

    //Gets the Managed Object Context:
    NSManagedObjectContext   * managedObjectContext      = [self managedObjectContext];
    VirtualMachineController * virtualMachineModelObject = [[VirtualMachineController alloc] initWithManagedObjectContext:managedObjectContext];
    
    if ([virtualMachineModelObject existsMachineNamed:newMachineName]) {
        DDLogVerbose(@"VM name is being used.");
        [newMachineErrorLabel setStringValue:@"Name is already in use."];
        [newMachineErrorLabel setHidden:NO];
        [virtualMachineModelObject release];
        [newMachineName release];
        return;
    }
    
    if (newVirtualMachineIdentifier == addNew) {
        [virtualMachineModelObject insertMachineNamed:newMachineName];
    } else if (newVirtualMachineIdentifier == duplicate) {
        //Machine to clone:
        VirtualMachinesEntityModel * machineToClone = [[virtualMachinesArrayController selectedObjects] objectAtIndex:0];
        [virtualMachineModelObject cloneMachine:machineToClone withName:newMachineName];
    } else if (newVirtualMachineIdentifier == importBasilisk) {
        NSArray * importedData = [[PreferencesController parsePreferencesFor:BasiliskII] retain];
        [virtualMachineModelObject insertMachineNamed:newMachineName withType:BasiliskII andData:importedData];
        [importedData release];
    } else if (newVirtualMachineIdentifier == importSheepShaver) {
        NSArray * importedData = [[PreferencesController parsePreferencesFor:Sheepshaver] retain];
        [virtualMachineModelObject insertMachineNamed:newMachineName withType:Sheepshaver andData:importedData];
        [importedData release];
    }
    
    [self selectLastCreatedVirtualMachine:sender];
    [self endNewMachineView:sender];
    [virtualMachineModelObject release];
    [newMachineName release];
    newVirtualMachineIdentifier = noAction;

}

/*!
 * @method      selectLastCreatedVirtualMachine:
 * @abstract    Selects last inserted VM.
 */
- (void)selectLastCreatedVirtualMachine:(id)sender {
    BOOL openDetailsAfterCreation = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"openDetailsAfterCreation"
    ];

    //Focus in the new item.
    [virtualMachinesArrayController
        setSelectedObjects:
        [NSArray arrayWithObject:
            [[virtualMachinesArrayController arrangedObjects] lastObject]
        ]
    ];

    //Release all
    if (openDetailsAfterCreation == YES) {
        [self openVirtualMachineWindow:sender];
    }
}

/*!
 * @method      deleteVirtualMachine:
 * @abstract    Deletes a virtual machine.
 * @discussion  It deletes the DB entry of the selected VM, deletes the
 *              preferences file and releases the window assigned to this
 *              VM. The releasing will make XCode complain, but the counting
 *              should be fine and there should be no memory leaks.
 */
- (IBAction)deleteVirtualMachine:(id)sender {
    
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];

    [managedObjectContext processPendingChanges];
    
    NSArray * selectedVirtualMachines = [[
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ] autorelease ];

    //The user can select only one in the current interface, but anyway...
    VirtualMachinesEntityModel * virtualMachine = [selectedVirtualMachines objectAtIndex:0];
    
    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;

    DDLogInfo(@"Attempting to delete file: %@", preferencesFilePath);
    if([fileManager fileExistsAtPath:preferencesFilePath isDirectory:nil]) {
        DDLogInfo(@"File exists.");
        if (![fileManager removeItemAtPath:preferencesFilePath error:&error]) {
            DDLogError(@"Whoops, couldn't delete: %@", preferencesFilePath);
        } else {
            DDLogInfo(@"File should be deleted!");
        }
    } else {
        DDLogInfo(@"File doesn't exist: %@", preferencesFilePath);
    }
    
    [preferencesFilePath release];
    
    if ([windowsForVirtualMachines objectForKey:[virtualMachine uniqueName]] != nil) {
        VirtualMachineWindowController * deletedVm = [windowsForVirtualMachines objectForKey:[virtualMachine uniqueName]];
        DDLogInfo(@"count of retain: %lu", [deletedVm retainCount]);
        [windowsForVirtualMachines removeObjectForKey:[virtualMachine uniqueName]];
        [[deletedVm window] close];
        DDLogInfo(@"count of retain: %lu", [deletedVm retainCount]);
        [deletedVm release];
    }
    
    // This code complains of double-releasing the pool, but... if it doesn't, it will crash by deleting related assets like emulators.
    // Find a solution!

    [managedObjectContext deleteObject:virtualMachine];

    [self endDeleteMachineView:sender];
    [self saveCoreData];

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Buttons' actions

#pragma mark – Button actions

/*!
 * @method      savePreferencesFile:
 * @abstract    Saves the virtual machine's preference file to be used
 *              by the emulator.
 */
- (IBAction)savePreferencesFile:(id)sender {
    [self saveCoreData];
    VirtualMachinesEntityModel * virtualMachine = [[virtualMachinesArrayController selectedObjects] objectAtIndex:0];

    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];
   
    PreferencesController * preferences = [[PreferencesController alloc] autorelease];
    [preferences savePreferencesFile:preferencesFilePath ForVirtualMachine:virtualMachine];
    DDLogVerbose(@"Prefs file ....: %@", preferencesFilePath);
    [preferencesFilePath release];
}

/*!
 * @method      openPreferencesFileFolder:
 * @abstract    Shows preferences file on Finder.
 */
- (IBAction)openPreferencesFileFolder:(id)sender {
    [self saveCoreData];
    VirtualMachinesEntityModel * virtualMachine = [[virtualMachinesArrayController selectedObjects] objectAtIndex:0];

    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];
   
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    [ws selectFile:preferencesFilePath inFileViewerRootedAtPath:nil];
    [preferencesFilePath release];
}

/*!
 * @method      showInformationWindow:
 * @abstract    Shows the advanced information window.
 * @discussion  The advanced information window is just like the VM list window,
 *              except that it displays the PID and some other handy info.
 */
- (IBAction)showInformationWindow:(id)sender {
    [informationWindow setIsVisible:YES];
    [informationWindow makeKeyAndOrderFront:sender];
}

/*!
 * @method      toggleEmulator:
 * @abstract    Turns virtual machine on and off.
 * @discussion  The original version had a button to turn the VM on and a button
 *              to stop it. I thought it could be much more simple to use a single
 *              button to handle both operations.
 */
- (IBAction)toggleEmulator:(VirtualMachinesEntityModel *)virtualMachine andSender:(id)sender {
    DDLogVerbose(@"Toggling %@", [virtualMachine running]);
    int currentStatus = [[virtualMachine running] intValue];
    if (currentStatus == 1) {
        DDLogVerbose(@"running, stop it!");
        [self stopEmulator:virtualMachine];
    } else {
        DDLogVerbose(@"still, run it!");
        [self run:virtualMachine andSender:sender];
    }
}

/*!
 * @method      toggleVirtualMachine:
 * @abstract    Turns virtual machine on and off.
 * @see         toggleEmulator:
 * @discussion  This action is triggered inside the table row.
 */
- (IBAction)toggleVirtualMachine:(id)sender {
    VirtualMachinesEntityModel * virtualMachine = [[virtualMachinesArrayController arrangedObjects] objectAtIndex:[sender clickedRow]];
    [self toggleEmulator:virtualMachine andSender:sender];
}

/*!
 * @method      stopEmulator:
 * @abstract    Sends a terminate signal to emulator process.
 * @discussion  This was originally intended to kill the emulator, but sending
 *              a termination signal simply prompts the emulator to shut down
 *              just like trying to turn off a real Macintosh. It will then
 *              proceed to prompt the user about it. The function is handy,
 *              nevertheless, and remained here.
 */
- (IBAction)stopEmulator:(VirtualMachinesEntityModel *)virtualMachine {
    if ([virtualMachine running]) {
        NSTask * theTask = [virtualMachineTasks objectForKey:[virtualMachine uniqueName]];        
        [theTask terminate];
    }
}

/*!
 * @method      killEmulator:
 * @abstract    Kills emulator process (SIGKILL).
 * @discussion  This is not the optimal solution, but it is all that could be
 *              done for the moment. The best way would be adding the emulator
 *              process into Medusa's process group and sending a message to
 *              the emulator to be terminated. Somehow, I can't use C to force
 *              a NSTask to belong to the parent's group, and if the parent
 *              dies, the children are re-assigned and keep running. So the
 *              only solution was to use the 'kill' command.
 */
- (IBAction)killEmulator:(id)sender {
    DDLogInfo(@"Attemptying to kill emulator.");
    VirtualMachinesEntityModel * virtualMachine = [[virtualMachinesArrayController selectedObjects] objectAtIndex:0];
    NSTask * runningTask = [virtualMachineTasks objectForKey:[virtualMachine uniqueName]];
    if ([virtualMachine running]) {
        NSString * command = [[[NSString alloc] initWithFormat:@"kill -9 %d", [runningTask processIdentifier]] autorelease];
        system([command UTF8String]);
    }
}

/*!
 * @method      run:
 * @abstract    Saves preferences and lauches emulator.
 * @discussion  This will launch the emulator as a child process.
 *              There is an issue on the parenting, refer to the kill
 *              method for more information.
 *
 * Old comment to be checked:
 * This will crash if the application support dir doesn't exist. Fix it!
 */
- (IBAction)run:(VirtualMachinesEntityModel *)virtualMachine andSender:(id)sender {
    
    [self saveCoreData];
   
    if (![virtualMachine romFile]){
        [errorSheetLabel setStringValue:@"There is no ROM file associated with this virtual machine!\nPlease check your ROM files on the assets manager and then use the general tab in your machine's settings.\nIf you need help, refer to the help menu."];
        [self showErrorSheetView:sender];
        return;
    }
    
    if (![[virtualMachine emulator] unixPath]){
        [errorSheetLabel setStringValue:@"There is no emulator associated with this virtual machine!\nPlease check your emulator on the assets manager and then use the general tab in your machine's settings.\nIf you need help, refer to the help menu."];
        [self showErrorSheetView:sender];
        return;
    }
    
    if ([[virtualMachine disks] count] == 0){
        [errorSheetLabel setStringValue:@"There are no disk files associated with this virtual machine!\nPlease check your disk files on the assets manager and then use the disks tab in your machine's settings.\nIf you need help, refer to the help menu."];
        [self showErrorSheetView:sender];
        return;
    }
    
    int usedDisks = 0;
    int busyDisks = 0;
    NSEnumerator * rowEnumerator = [[virtualMachine disks] objectEnumerator];
    RelationshipVirtualMachinesDiskFilesEntityModel * object;
    while (object = [rowEnumerator nextObject]) {
        DiskFilesEntityModel * driveObject = [object diskFile];
        BOOL busy = [FileManager pidsAccessingPath:[driveObject filePath]];
        DDLogInfo(@"Disk busy: %@", busy ? @"yes" : @"no");
        if (busy) {
            busyDisks++;
        }
        DDLogVerbose(@"---- %@", [driveObject blocked]);
        if ([[driveObject blocked] boolValue]) {
            usedDisks++;
        }
    }
    
    if (usedDisks > 0) {
        [errorSheetLabel setStringValue:[
            NSString stringWithFormat: @"There %@ disk%@ being used by this virtual machine right now!\nIf you use the same disks in two emulations at the same time, the data becomes corrupted!\nPlease stop the other emulation before booting this machine."
            , usedDisks > 1 ? @"are" : @"is a", usedDisks > 1 ? @"s" : @""
        ]];
        [self showErrorSheetView:sender];
        return;
    }
    if (busyDisks > 0) {
        [errorSheetLabel setStringValue:[
            NSString stringWithFormat: @"There %@ disk%@ being used by another application right now!\nPlease verify if the images are mounted and unmount them before proceeding."
            , busyDisks > 1 ? @"are" : @"is a", busyDisks > 1 ? @"s" : @""
        ]];
        [self showErrorSheetView:sender];
        return;
    }

    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];
   
    PreferencesController * preferences = [[PreferencesController alloc] autorelease];
    [preferences savePreferencesFile:preferencesFilePath
                   ForVirtualMachine:virtualMachine];

    DDLogVerbose(@"Prefs file ....: %@", preferencesFilePath);
    
///-----------------------------------------------------------------------------

    // Use GCD to execute emulator in an async thread:
    dispatch_async(queue, ^{
        
        // Blocks all used disks:
        NSEnumerator * rowEnumerator = [[virtualMachine disks] objectEnumerator];
        RelationshipVirtualMachinesDiskFilesEntityModel * object;
        while (object = [rowEnumerator nextObject]) {
            DiskFilesEntityModel * driveObject = [object diskFile];
            [driveObject setBlocked:[NSNumber numberWithBool:YES]];
        }
        
        NSString * emulatorPath = [[virtualMachine emulator] unixPath];

        // Starts emulator:
        
        NSTask * emulatorTask = [[[NSTask alloc] init] autorelease];
        [emulatorTask setLaunchPath:emulatorPath];

        if ([[[virtualMachine emulator] family] intValue] == basiliskFamily) {
            [emulatorTask setArguments:
                [NSArray arrayWithObjects:
                     @"--config"
                   , preferencesFilePath
                   ,nil
                ]
            ];
        } else
        if ([[[virtualMachine emulator] family] intValue] == sheepshaverFamily) {
            [emulatorTask setArguments:
                [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%@.sheepvm", preferencesFilePath], nil
                ]
            ];
        }
    
        [preferencesFilePath release];
        [emulatorTask launch];
        
        [virtualMachine setRunning:[NSNumber numberWithBool:YES]];

        [virtualMachineTasks setObject:emulatorTask forKey:[virtualMachine uniqueName]];
        
        [virtualMachine setTaskPID:[NSNumber numberWithInt:[emulatorTask processIdentifier]]];

        [emulatorTask waitUntilExit];

        [virtualMachine setRunning:[NSNumber numberWithBool:NO]];
        [virtualMachine setTaskPID:[NSNumber numberWithInt:0]];

        [virtualMachineTasks removeObjectForKey:[virtualMachine uniqueName]];

        // Unblocks all used disks:
        rowEnumerator = [[virtualMachine disks] objectEnumerator];
        while (object = [rowEnumerator nextObject]) {
            DiskFilesEntityModel * driveObject = [object diskFile];
            [driveObject setBlocked:[NSNumber numberWithBool:NO]];
        }

        DDLogVerbose(@"Emulator finished.");
        
        [self performCleanUp];
        
    });
///-----------------------------------------------------------------------------
    
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Open Window Actions

#pragma mark – Windows triggers

- (IBAction)showMainWindow:(id)sender {
    [_window makeKeyAndOrderFront:self];
}

/*!
 * @method      openVirtualMachineWindow:
 * @abstract    Opens the iTunes-like window to control the vm's properties.
 */
- (IBAction)openVirtualMachineWindow:(id)sender {
    
    NSArray * selectedVirtualMachines = [[
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ] autorelease];
    // The user can select only one in the current interface, but anyway...

    VirtualMachinesEntityModel * selectedVirtualMachine = [selectedVirtualMachines objectAtIndex:0];
    VirtualMachineWindowController * newWindowController = [windowsForVirtualMachines objectForKey:[selectedVirtualMachine uniqueName]];
    
    if (newWindowController == nil) {
        DDLogVerbose(@"Missing window for key %@", [selectedVirtualMachine uniqueName]);
        newWindowController = [
            [VirtualMachineWindowController alloc]
                initWithVirtualMachine: selectedVirtualMachine
                inManagedObjectContext: [self managedObjectContext]
        ]; // Closing won't release it.
        [windowsForVirtualMachines setObject:newWindowController forKey:[selectedVirtualMachine uniqueName]];
    }

    [newWindowController showWindow:sender];
    
}

/*!
 * @method      showAssetsWindow:
 * @abstract    Displays the Assets Window.
 */
- (IBAction)showAssetsWindow:(id)sender {
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];
    if (!assetsWindowController) {
        assetsWindowController = [
            [AssetsWindowController alloc]
                initWithManagedObjectContext: managedObjectContext
        ];
    }
    [assetsWindowController showWindow:self];
}

// Preferences:
/*!
 * @method      showPreferencesWindow:
 * @abstract    Displays the Preferences.
 */
- (IBAction)showPreferencesWindow:(id)sender {
    if (!preferencesWindowController) {
        preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [preferencesWindowController showWindow:self];
}

//------------------------------------------------------------------------------
// Utility methods

#pragma mark – Utility

/*!
 * @method      applicationSupportDirectory:
 * @abstract    Returns the application support directory path.
 */
- (NSString *)applicationSupportDirectory {
    NSArray  * paths    = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Medusa"];
}

/*!
 * @method      saveCoreData:
 * @abstract    Saves the core-data state.
 */
- (void)saveCoreData {
    DDLogVerbose(@"Saving...");
    NSError * error = nil;
    if (![[self managedObjectContext] save:&error]) {
        DDLogError(@"Whoops, couldn't save: %@\n\n%@", [error localizedDescription], [error userInfo]);
        DDLogVerbose(@"Check 'App Delegate' class, saveCloneVirtualMachine");
    }
}

/*!
 * @method      popUpDialog:
 * @abstract    Triggers a pop-up window.
 */
- (void)popUpDialog:(NSString *)prompt {
    NSAlert * alert = [[[NSAlert alloc] init] autorelease];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:@"Migration"];
    [alert setInformativeText:prompt];
    [alert runModal];
}

/*!
 * @method      popUpMessage:WithTitle:
 * @abstract    Triggers a pop-up window.
 */
- (void)popUpMessage:(NSString *)message WithTitle:(NSString *)title {
    NSAlert * alert = [[[NSAlert alloc] init] autorelease];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert runModal];
}

/*!
 * @method      performCleanUp:
 * @abstract    Removes XPRAM files from home dir.
 */
- (void)performCleanUp {
    BOOL leaveXPRAM = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"leaveXPRAM"
    ];
    if (leaveXPRAM == NO)
        if ([virtualMachineTasks count] == 0)
            [FileManager deleteXPRAMFile];
//    [self resetButtons];
    [virtualMachinesList reloadData];
}

///*!
// * @method      resetButtons:
// * @abstract    Re-designs interface.
// * @warning     I think this is outdated.
// */
//- (void)resetButtons {
//    DDLogVerbose(@"Reseting buttons");
//    [virtualMachinesList reloadData];
//    if ([[virtualMachinesArrayController selectedObjects] count] > 0){
//        if ([[[virtualMachinesArrayController selectedObjects] objectAtIndex:0] canRun]) {
//            [runButton setEnabled:YES];
//        } else {
//            [runButton setEnabled:NO];
//        }
//    }
//}

///*!
// * @method      windowDidBecomeKey:
// * @abstract    Triggered by observer every time the window gets focus.
// */
//- (void)windowDidBecomeKey:(NSNotification *)notification {
//    [self resetButtons];
//}

/*!
 * @method      updateVMWindows:
 * @abstract    Triggered by other controllers every time something must be
 *              updated in the VM interface.
 */
- (void)updateVMWindows {
    for(NSString * currentWindowControllerKey in windowsForVirtualMachines) {
        VirtualMachineWindowController * currentWindowController = [windowsForVirtualMachines valueForKey:currentWindowControllerKey];
        [currentWindowController updateWindow];
    }
}

//------------------------------------------------------------------------------
// Overwritten methods.

#pragma mark – Rewrotten

/*!
 * @method      applicationShouldHandleReopen:hasVisibleWindows:
 * @abstract    Defines if the main window should re-open after a click in the
 *              Dock's icon once all windows are closed.
 */
- (BOOL)applicationShouldHandleReopen:(NSApplication *)app hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [_window makeKeyAndOrderFront:self];
        return NO;
    } else {
        return YES;
    }
}

// Init methods

#pragma mark – Init

/*!
 * @method      init
 * @abstract    Init method.
 */
- (id)init {
    self = [super init];
    if (self) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        windowsForVirtualMachines = [[NSMutableDictionary alloc] init];
        virtualMachineTasks = [[NSMutableDictionary alloc] init];
        //[[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"ClassicFolderIcon.icns"] forFile:[@"~/Classic" stringByExpandingTildeInPath] options:0];
        newVirtualMachineIdentifier = noAction;
    }
    return self;
}

//------------------------------------------------------------------------------
// Standard methods.

#pragma mark – Standard methods

//The comments are not part of Apple's policies, it seems.. *sigh*

/*!
 * @link Check XCode quick help.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    //Log all preferences:
    //DDLogVerbose(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    // Resolves all bookmarks:
    [FileManager resolveBookmarksInObjectContext:[self managedObjectContext]];
    
    //Preferences management:
    BOOL haveSharePath = [[NSUserDefaults standardUserDefaults] boolForKey:@"haveSharePath"];
    
    //Share path:
    if (!haveSharePath) {
        [[NSUserDefaults standardUserDefaults] setValue: NSHomeDirectory()
        forKey:@"StandardSharePath"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"haveSharePath"];
    }
    
    // Checks for application support directory:
    BOOL isDir;
    NSString      * applicationSupportDirectoryPath = [self applicationSupportDirectory];
    NSFileManager * fileManager                     = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:applicationSupportDirectoryPath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:applicationSupportDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL])
            DDLogError(@"Error: Create application support dir failed.");
    
    // Checks for emulators:
    
    BOOL haveEmulators = [[NSUserDefaults standardUserDefaults] boolForKey:@"emulatorsUsed"];
    
    if (!haveEmulators) {
        [self showAssetsWindow:self];
        [assetsWindowController displayEmulatorsView:self];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
//    NSLog(@"registering");
    if (![[NSHelpManager sharedHelpManager] registerBooksInBundle:[NSBundle mainBundle]]) {
        DDLogError(@"Failed to register Help Book.");
    }

}

/*!
 * @method      applicationFilesDirectory:
 * @abstract    Returns the directory the application uses to store the Core Data
 *              store file.
 * @discussion  This code uses a directory named "Medusa" in the user's Library
 *              directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSURL * libraryURL = [
        [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject
    ];
    
    return [libraryURL URLByAppendingPathComponent:@"Medusa"];
}

/*!
 * @method      managedObjectModel:
 * @abstract    Creates if necessary and returns the managed object model for
 *              the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) return __managedObjectModel;
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"Medusa" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 * @method      persistentStoreCoordinator:
 * @abstract    Returns the persistent store coordinator for the application.
 *              This implementation creates and return a coordinator, having
 *              added the store for the application to it. (The directory for
 *              the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    // Return if already set:
    if (__persistentStoreCoordinator) return __persistentStoreCoordinator;

    // Core-data information
    int bundlesVersion = 1205;
    NSString * bundlesVersionString = [[NSString alloc] initWithString:@"1.2.0.5"];
    //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    // Managed object model:
    // (A file containing the definition of an application's data structure)
    NSManagedObjectModel * managedObjectModel = [self managedObjectModel];
    
    if (!managedObjectModel) {
        DDLogError(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
   
    // -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    // Locate the existent data dir:
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL         * applicationFilesDirectory = [self applicationFilesDirectory];
    NSError       * error = nil;
    NSDictionary  * properties = [
        applicationFilesDirectory
        resourceValuesForKeys:[
            NSArray arrayWithObject:NSURLIsDirectoryKey
        ]
        error:&error
    ];

    if (!properties) {
        if ([error code] == NSFileReadNoSuchFileError) {
            DDLogError(@"No application files dir, attempting to create one");
            if (![fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error]){
                DDLogError(@"Couldn't create application files dir!");
                [[NSApplication sharedApplication] presentError:error];
                return nil;
            }
        }
    }

    // -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    // Getting data file:
    NSURL * persistentStoreUrl = [applicationFilesDirectory URLByAppendingPathComponent:@"Medusa.storedata"];
    BOOL persistentStoreExists = [fileManager fileExistsAtPath:[persistentStoreUrl path]];

    if (persistentStoreExists == YES) {
        
        //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        // Load metadata:
        NSDictionary * persistentStoreMetadata = [
            NSPersistentStoreCoordinator
                metadataForPersistentStoreOfType:NSSQLiteStoreType
                                             URL:persistentStoreUrl
                                           error:&error
        ];

        //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        // Read current version:
        NSArray  * sourceVersionIdentifiers = [persistentStoreMetadata objectForKey:NSStoreModelVersionIdentifiersKey];
        NSString * sourceVersionString = [[[NSString alloc] initWithString:[sourceVersionIdentifiers lastObject]] autorelease];
        DDLogInfo(@"... Current version of .xcdatamodeld file: %@", sourceVersionString);
        DDLogInfo(@"... Version expected in this bundle .....: %@", bundlesVersionString);
        //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        // Check if data is compatible and requires migration:
        BOOL pscCompatibile = [managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:persistentStoreMetadata];
        
        //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        // Migration code!

        if (pscCompatibile == NO) {
            DDLogWarn(@"### Need to migrate!");
            NSString * versionString = [sourceVersionString stringByReplacingOccurrencesOfString:@"." withString:@""];
            int persistedVersion = [versionString intValue];
            
            // Persisted version is higher than current app supports:
            if (persistedVersion > bundlesVersion) {
                [self popUpDialog:[NSString stringWithFormat:@"Medusa seems to have found a newer version of its data file. (%@ < %@)\nPlease either update Medusa or delete the data file, in which case your data will be lost. =(", bundlesVersionString, sourceVersionString]];
                DDLogWarn(@"Medusa is terminating because data is from newer version!");
                DDLogWarn(@"Version I can understand: %@", bundlesVersionString);
                DDLogWarn(@"Version I found instead:  %@", sourceVersionString);
                [NSApp terminate:nil];
            }
            
            //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            // Migration process:
            
            NSArray * mappingModelNames = [NSArray arrayWithObjects:
                @"MappingModel-1.1.0.8-1.2.0.1",
                @"MappingModel-1.2.0.1-1.2.0.2",
                @"MappingModel-1.2.0.2-1.2.0.3",
                @"MappingModel-1.2.0.3-1.2.0.4",
                @"MappingModel-1.2.0.4-1.2.0.5"
            , nil];

            NSString     * sourceStoreType         = NSSQLiteStoreType;
            NSDictionary * sourceStoreOptions      = nil;
            NSURL        * destinationStoreURL     = [applicationFilesDirectory URLByAppendingPathComponent:@"Medusa2.sqlite"];
            NSString     * destinationStoreType    = NSSQLiteStoreType;
            NSDictionary * destinationStoreOptions = nil;
            DDLogVerbose(@" ->  persistentStoreUrl: %@", persistentStoreUrl);
            DDLogVerbose(@" -> destinationStoreURL: %@", destinationStoreURL);
            
            // Creates a new Object Model for original data and a Migration Manager:
            NSManagedObjectModel * sourceObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:persistentStoreMetadata];
            NSMigrationManager   * migrationManager  = [
                [NSMigrationManager alloc]
                    initWithSourceModel:sourceObjectModel
                       destinationModel:managedObjectModel
            ];

            // Assembles prefix of the first mapping to be used:
            NSString * originalVersionString = [[NSString alloc] initWithFormat:@"MappingModel-%@", sourceVersionString];
            BOOL migrateFurther = NO;
            BOOL allOkay = YES;

            //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            // Loop to iterate migration maps:
            for (NSString * mappingModelName in mappingModelNames) {
                NSURL * fileURL = [[NSBundle mainBundle] URLForResource:mappingModelName withExtension:@"cdm"];
                NSRange mapHasVersion = [mappingModelName rangeOfString:originalVersionString];
                BOOL ok = NO;

                // First migration:
                if (mapHasVersion.location != NSNotFound) {
                    DDLogVerbose(@"-+- First migration step");
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    // Attempting to fix hashes for entities:
                    // This is being tested.
                    
                    NSMappingModel * mappingModel      = [[NSMappingModel alloc] initWithContentsOfURL:fileURL];
                    NSArray        * newEntityMappings = [NSArray arrayWithArray:mappingModel.entityMappings];
                    
                    DDLogVerbose(@"map: %@", mappingModelName);
                    
                    for (NSEntityMapping * entityMapping in newEntityMappings) {
                        [entityMapping setSourceEntityVersionHash:[
                             sourceObjectModel.entityVersionHashesByName valueForKey:entityMapping.sourceEntityName
                        ]];
                        [entityMapping setDestinationEntityVersionHash:[
                             managedObjectModel.entityVersionHashesByName valueForKey:entityMapping.destinationEntityName
                        ]];
                    }
                    mappingModel.entityMappings = newEntityMappings;
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    
                    @try {
                        ok = [migrationManager migrateStoreFromURL:persistentStoreUrl
                                                              type:sourceStoreType
                                                           options:sourceStoreOptions
                                                  withMappingModel:mappingModel
                                                  toDestinationURL:destinationStoreURL
                                                   destinationType:destinationStoreType
                                                destinationOptions:destinationStoreOptions
                                                             error:&error];

                    } @catch (id theException) {
                        DDLogInfo(@"%@ won't respond to migration method", mappingModelName);
                        DDLogVerbose(@"\n----\nError:\n\n%@\n\n----\n", error==nil?theException:error);
                        DDLogError(@"Error: %@ (mapping model: %@)\n", error==nil?theException:error, mappingModelName);
                    } @finally {
                        if (ok) {
                            DDLogInfo(@"+++ Migration named '%@' successful", mappingModelName);
                            migrateFurther = YES;
                            allOkay = allOkay && YES;
                        } else {
                            DDLogError(@"%@", error);
                            DDLogError(@"+++ Migration named '%@' failed", mappingModelName);
                            allOkay = allOkay && NO;
                            [self popUpDialog:@"Migration failed!"];
                            [NSApp terminate:nil];
                        }
                    }
                    [mappingModel release];
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    
                } else

                // Further migrations:
                if (migrateFurther) {
                    
                    DDLogVerbose(@"-+- Migrate further");
                    
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    // New data reference to be able to save new information.
                    // This is being tested.
                    
                    
                    NSDictionary * newPersistentStoreMetadata = [
                        NSPersistentStoreCoordinator
                            metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                         URL:persistentStoreUrl
                                                       error:&error
                    ];
                    
                    NSManagedObjectModel * newSourceModel = [
                        NSManagedObjectModel
                            mergedModelFromBundles:nil
                                  forStoreMetadata:newPersistentStoreMetadata
                    ];
                    
                    
                    NSMigrationManager * newMigrationManager = [
                        [NSMigrationManager alloc]
                            initWithSourceModel:newSourceModel
                               destinationModel:managedObjectModel
                    ];
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    // Attempting to fix hashes for entities:
                    // This is being tested.

                    NSMappingModel * mappingModel = [[NSMappingModel alloc] initWithContentsOfURL:fileURL];

                    NSArray * newEntityMappings = [NSArray arrayWithArray:mappingModel.entityMappings];
                    for (NSEntityMapping * entityMapping in newEntityMappings) {
                        [entityMapping setSourceEntityVersionHash:[
                             newSourceModel.entityVersionHashesByName valueForKey:entityMapping.sourceEntityName
                        ]];
                        [entityMapping setDestinationEntityVersionHash:[
                             managedObjectModel.entityVersionHashesByName valueForKey:entityMapping.destinationEntityName
                        ]];
                    }
                    mappingModel.entityMappings = newEntityMappings;
                    
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

                    @try {
                        ok = [newMigrationManager migrateStoreFromURL:persistentStoreUrl
                                                                 type:sourceStoreType
                                                              options:sourceStoreOptions
                                                     withMappingModel:mappingModel
                                                     toDestinationURL:destinationStoreURL
                                                      destinationType:destinationStoreType
                                                   destinationOptions:destinationStoreOptions
                                                                error:&error];
                        
                    } @catch (id theException) {
                        DDLogInfo(@"%@ won't respond to migration method", mappingModelName);
                        DDLogVerbose(@"\n----\nError:\n\n%@\n\n----\n", error==nil?theException:error);
                        DDLogError(@"Error: %@ (mapping model: %@)\n", error==nil?theException:error, mappingModelName);
                    } @finally {
                        if (ok) {
                            DDLogInfo(@"+++ Migration named '%@' successful", mappingModelName);
                            migrateFurther = YES;
                            allOkay = allOkay && YES;
                        } else {
                            DDLogError(@"Migration named '%@' failed", mappingModelName);
                            DDLogVerbose(@"\n----\nError:\n\n%@\n\n----\n", error);
                            allOkay = allOkay && NO;
                            [self popUpDialog:@"+++ Migration failed!"];
                            [NSApp terminate:nil];
                        }
                    }
                    [mappingModel release];
                    [newMigrationManager release];
                }
                
                //  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
                // Manual fixing:

                if (ok) {
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

                    NSPersistentStoreCoordinator * tempCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
                    [tempCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:destinationStoreURL
                                                        options:nil
                                                          error:&error];
                    NSManagedObjectContext * tempMOC = [[NSManagedObjectContext alloc] init];
                    [tempMOC setPersistentStoreCoordinator:tempCoordinator];
                    DDLogVerbose(@"-+- Assistant for map: %@", mappingModelName);
                    [MigrationAssistant
                        executeMigrationChangesFor:mappingModelName
                            InManagedObjectContext:tempMOC
                    ];
                    [tempMOC release];
                    [tempCoordinator release];
                     
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                    // Replace old database for new:

                    NSError * error2 = nil;
                    NSFileManager * fileManager = [[NSFileManager alloc] init];

                    if ([fileManager fileExistsAtPath:[persistentStoreUrl path]] == YES) {
                        if ([fileManager removeItemAtPath:[persistentStoreUrl path] error:&error2])
                            DDLogInfo(@"Datastore removed");
                        else
                            DDLogError(@"Datastore not removed");
                    } else {
                        DDLogError(@"Datastore doesn't exist!");
                    }

                    if ([fileManager moveItemAtURL:destinationStoreURL toURL:persistentStoreUrl error:&error2]) {
                        DDLogInfo(@"Datastore moved");
                    } else {
                        DDLogError(@"Datastore not moved");
                    }

                    [fileManager release];
                    
                    // -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

                }
            }

            //-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

            [originalVersionString release];
            [migrationManager release];
            
//            if (allOkay == YES) {
//                [self popUpMessage:@"Medusa sucessfully migrated your data from the previous version." WithTitle:@"Success"];
//            }
        }
    }

    [bundlesVersionString release];

    // -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    // A new coordinator:
    // (An object that mediates between Persistent Stores and Managed Object
    // Contexts as per the Managed Object Model)
    NSPersistentStoreCoordinator * coordinator = [
        [[NSPersistentStoreCoordinator alloc]
             initWithManagedObjectModel:managedObjectModel
        ] autorelease
    ];

// Lightweight migrations:
//    NSDictionary * storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
//       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
//       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
//    nil];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:persistentStoreUrl options:nil error:&error];
    __persistentStoreCoordinator = [coordinator retain];
    return __persistentStoreCoordinator;
}


/**
 * @method        managedObjectContext:
 * @discussion    Returns the managed object context for the application (which is already
 *                bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError * error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
     __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
 * @method        windowWillReturnUndoManager:
 * @discussion    Returns the NSUndoManager for the application. In this case,
 *                the manager returned is that of the managed object context for
 *                the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
 * @method        saveAction:
 * @discussion    Performs the save action for the application, which is to send
 *                the save: message to the application's managed object context.
 *                Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError * error = nil;
    if (![[self managedObjectContext] commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/**
 * @method        applicationShouldTerminate:
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError * error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString * question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString * info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString * quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString * cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert  * alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

/**
 * @method        initialize:
 */
+ (void)initialize {
    IconValueTransformer * transformer = [[IconValueTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"IconValueTransformer"];
    [transformer release];
}

@end
