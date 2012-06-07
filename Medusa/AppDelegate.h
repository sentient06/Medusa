//
//  AppDelegate.h
//  Medusa
//
//  Created by Giancarlo Mariot on 10/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
@class RomManagerWindowController; //Rom Manager Window
@class DriveManagerWindowController; //Drive Manager Window
@class PreferencesWindowController; //Preferences Window
@class SplashWindowController;

/*!
 * @class       AppDelegate:
 * @abstract    Responsible for all the OS interaction, for short.
 * @discussion  This is the main class of this project. Maybe in the future I
 *              will transfer the main functionality of the data handling to a
 *              new class. But lets keep it simple until we need that.
 */
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    IBOutlet NSArrayController  *virtualMachinesArrayController;
    //Array controller to keep track of the machines list.
    IBOutlet NSPanel            *newMachineView;
    //Sheet used to create a new machine.
    IBOutlet NSTextField        *newMachineNameField;
    //Text field in the new machine sheet.
    IBOutlet NSPopUpButton      *newMachineModelField;
    //Pop up button with the model (rom file).
    IBOutlet NSArrayController  *romFilesController;
    //Array controller with the model (rom file).
    
    IBOutlet NSObjectController *newVirtualMachineController;
    
    //Window Controllers:
    RomManagerWindowController      *romWindowController;
    DriveManagerWindowController    *driveWindowController;
    PreferencesWindowController     *preferencesWindowController;
    SplashWindowController          *splashWindowController;
    
    /// 32-bit compatibility -------    
    id _window;
    id __persistentStoreCoordinator;
    id __managedObjectModel;
    id __managedObjectContext;
    /// ----------------------------
}

//------------------------------------------------------------------------------
// Default properties ahead.

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


//------------------------------------------------------------------------------
// Default methods ahead.

- (IBAction)saveAction:(id)sender; //don't remember...

//------------------------------------------------------------------------------
// New methods ahead.

- (IBAction)saveNewVirtualMachine:(id)sender;
//Action to the button that creates the new entry in the coredata.

- (IBAction)openVirtualMachineWindow:(id)sender;
//Opens the iTunes-like window to control the machine's properties.

- (IBAction)showRomManagerWindow:(id)sender;
//Action to show the ROM Manager Window.

- (IBAction)showDriveManagerWindow:(id)sender;
//Action to show the Drive Manager Window.

- (IBAction)showPreferencesWindow:(id)sender;
//Action to show the Preferences Window.

@end
