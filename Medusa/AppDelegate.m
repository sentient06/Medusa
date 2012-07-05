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

#import "AppDelegate.h"
#import "VirtualMachineWindowController.h"  //VM Window
#import "RomManagerWindowController.h"      //Rom Manager Window
#import "DriveManagerWindowController.h"    //Drive Manager Window
#import "AssetsWindowController.h"          //Assets Window
#import "PreferencesWindowController.h"     //Preferences Window
#import "SplashWindowController.h"
#import "IconValueTransformer.h"            //Transforms a coredata integer in an icon
//Helpers:
#import "ManagedObjectCloner.h"             //Clone core-data objects
//Models:
#import "VirtualMachinesModel.h"
#import "RomFilesModel.h"

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
    [super dealloc];
}

//------------------------------------------------------------------------------
// Application methods.

#pragma mark – Main Window actions

/*!
 * @method      openVirtualMachineWindow:
 * @abstract    Opens the iTunes-like window to control the vm's properties.
 */
- (IBAction)openVirtualMachineWindow:(id)sender{
    
    NSArray *selectedVirtualMachines = [
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ];
    //The user can select only one in the current interface, but anyway...
    
    VirtualMachinesModel * selectedVirtualMachine;
    
    for (int i = 0; i < [selectedVirtualMachines count]; i++) {
        
        selectedVirtualMachine = [selectedVirtualMachines  objectAtIndex:i];
        
        VirtualMachineWindowController *newWindowController = [
            [VirtualMachineWindowController alloc]
                initWithVirtualMachine: selectedVirtualMachine
                inManagedObjectContext: [self managedObjectContext]
        ];
        
        //[newWindowController setShouldCloseDocument:NO];
        //[self addWindowController:newWindowController];
        [newWindowController showWindow:sender];
        
    }
    
    [selectedVirtualMachines release];
    
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// New Virtual machines

// New VM:

/*!
 * @method      showNewMachineView:
 * @abstract    Displays the new VM sheet.
 */
- (IBAction)showNewMachineView:(id)sender {
    
    [ NSApp
            beginSheet: newMachineView
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
    
    [newMachineNameField setStringValue:@""];
    [newMachineModelField selectItemAtIndex:0];
    [NSApp endSheet:newMachineView];
    [newMachineView orderOut:sender];
    
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

    BOOL openDetailsAfterCreation = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"openDetailsAfterCreation"
    ];

    //Gets the Managed Object Context:
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];

    //Sets a new vm object.
    VirtualMachinesModel * newVirtualMachineObject = [
        NSEntityDescription
            insertNewObjectForEntityForName:@"VirtualMachines"
                     inManagedObjectContext:managedObjectContext
    ];
    

    //--------------------------------------------------------------------------
    
    //Here we have all the fields to be inserted.
    [newVirtualMachineObject setName:[newMachineNameField stringValue]];

    NSLog(@"%@", [romFilesController selectedObjects]);
    //NSLog(@"%@", [newMachineModelField ])
    
    
    
    [newVirtualMachineObject setRomFile:[[romFilesController selectedObjects] objectAtIndex:0]];
       
    //--------------------------------------------------------------------------
    // Save:
    
    NSLog(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSLog(@"Check 'App Delegate' class.");
    }
    
    //--------------------------------------------------------------------------
    //Focus in the new item.
    
    [virtualMachinesArrayController
        setSelectedObjects:
        [NSArray arrayWithObject:
            [[virtualMachinesArrayController arrangedObjects] lastObject]
        ]
    ];
    
    //--------------------------------------------------------------------------
    //Open item's window if user specified.    

    [self endNewMachineView:sender];
    
    if (openDetailsAfterCreation == YES) {
        [self openVirtualMachineWindow:sender];
    }
    
}

// Clone VM:

/*!
 * @method      showNewMachineView:
 * @abstract    Displays the new VM sheet.
 */
- (IBAction)showCloneMachineView:(id)sender {
    
    [ NSApp
            beginSheet: cloneMachineView
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
- (IBAction)endCloneMachineView:(id)sender {
    
    [cloneMachineNameField setStringValue:@""];
    [NSApp endSheet:cloneMachineView];
    [cloneMachineView orderOut:sender];
    
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
- (IBAction)saveCloneVirtualMachine:(id)sender {

    BOOL openDetailsAfterCreation = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"openDetailsAfterCreation"
    ];

    //Gets the Managed Object Context:
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];
    
    //Gets selected machine:
    NSArray * selectedVirtualMachines = [
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ];

    //Machine to clone:
    VirtualMachinesModel * machineToClone = [selectedVirtualMachines objectAtIndex:0];
    
    NSLog(@"Cloning machine called '%@'", [machineToClone name]);
    
    //Cloned machine:
    VirtualMachinesModel * clonedMachine = [machineToClone clone];
    
    //Change name:
    [clonedMachine setName:[cloneMachineNameField stringValue]];
    
    //--------------------------------------------------------------------------
    //Saving new clone:
    
    NSLog(@"Saving...");
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSLog(@"Check 'App Delegate' class, saveCloneVirtualMachine");
    }
    
    //--------------------------------------------------------------------------
    //Focus in the new item.
    
    [virtualMachinesArrayController
        setSelectedObjects:
        [NSArray arrayWithObject:
            [[virtualMachinesArrayController arrangedObjects] lastObject]
        ]
    ];

    //--------------------------------------------------------------------------
    //Release all
    
    [selectedVirtualMachines release]; //Selected machines
    
    [self endCloneMachineView:sender];
    
    if (openDetailsAfterCreation == YES) {
        [self openVirtualMachineWindow:sender];
    }
    
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Open Window Actions

#pragma mark – Windows triggers

// Rom Manager / Assets:

/*!
 * @method      showRomManagerWindow:
 * @abstract    Displays the Rom Manager.
 */
- (IBAction)showRomManagerWindow:(id)sender {
    
    BOOL useAssetsManager = [[NSUserDefaults standardUserDefaults] boolForKey:@"useAssetsManager"];
    
    if (useAssetsManager == YES) {
    
        [self showAssetsWindow:sender]; 
        
    }else{
        
        if (!romWindowController) {
            romWindowController = [
                [RomManagerWindowController alloc]
                    initWithWindowNibName:@"RomManagerWindow"
            ];
        }
        [romWindowController showWindow:self];  
        
    }
    
}

// Disks:

/*!
 * @method      showDriveManagerWindow:
 * @abstract    Displays the Drive Manager.
 */
- (IBAction)showDriveManagerWindow:(id)sender {
    
    if (!driveWindowController) {
        driveWindowController = [[DriveManagerWindowController alloc] initWithWindowNibName:@"DriveManagerWindow"];
    }
    [driveWindowController showWindow:self];  
    
}

// Assets:

/*!
 * @method      showAssetsWindow:
 * @abstract    Displays the Assets Window.
 */
- (IBAction)showAssetsWindow:(id)sender {
    
    //Gets the Managed Object Context:
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
    NSLog(@"Show preferences window: %@", sender);
    
    if (!preferencesWindowController) {
        NSLog(@"No controller");
        preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }else{
        NSLog(@"Controller ok");
    }
    [preferencesWindowController showWindow:self];  
    
}

//------------------------------------------------------------------------------
// Overwrotten methods.

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

//------------------------------------------------------------------------------
// Standard methods.

#pragma mark – Standard methods

//The comments are not part of Apple's policies, it seems.. *sigh*

/*!
 * @link Check XCode quick help.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    //Log all preferences:
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    //Preferences management:
    
    BOOL hideSplash = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideSplash"];
    BOOL haveSharePath = [[NSUserDefaults standardUserDefaults] boolForKey:@"haveSharePath"];
    
    //Splash window:
    if (!hideSplash) {
        if (!splashWindowController) {
            splashWindowController = [[SplashWindowController alloc] initWithWindowNibName:@"SplashWindow"];
        }
        [splashWindowController showWindow:self];  
    }
    
    //Share path:
    if (!haveSharePath) {
        [[NSUserDefaults standardUserDefaults] setValue: NSHomeDirectory()
        forKey:@"StandardSharePath"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"haveSharePath"];
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

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *libraryURL = [
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
	
    NSURL *modelURL = [
        [NSBundle mainBundle] URLForResource:@"Medusa" withExtension:@"momd"
    ];
    
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    
    return __managedObjectModel;

}

/**
 * @abstract    Returns the persistent store coordinator for the application.
 *              This implementation creates and return a coordinator, having
 *              added the store for the application to it. (The directory for
 *              the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    
    if (!mom) {
        NSLog(
              @"%@:%@ No model to generate a store from",
              [self class],
              NSStringFromSelector(_cmd)
        );
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [
        applicationFilesDirectory
        resourceValuesForKeys:[
            NSArray arrayWithObject:NSURLIsDirectoryKey
        ]
        error:&error
    ];
        
    if (!properties) {
        
        BOOL ok = NO;
        
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
        
    } else {
        
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
        
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Medusa.storedata"];
    
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    
    NSSet *versionIdentifiers = [[self managedObjectModel] versionIdentifiers];
    NSLog(@"Which Current Version is our .xcdatamodeld file set to? %@", versionIdentifiers);
    
    /*
     This part handles the persistent store upgrade:
     */
    NSDictionary *options = [
                             NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption,
                             nil
                             ];
    
    /*
     The following code was without 'options'. The value was set to 'nil'.
     */
    if (![coordinator
          addPersistentStoreWithType:NSSQLiteStoreType
                       configuration:nil
                                 URL:url
                             options:options
                               error:&error]) {

        //[[NSApplication sharedApplication] presentError:error];
        
        return nil;
    }
    __persistentStoreCoordinator = [coordinator retain];

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
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




+ (void)initialize {
    IconValueTransformer *transformer = [[IconValueTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"IconValueTransformer"];
    [transformer release];
}

@end
