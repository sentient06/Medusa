//
//  AppDelegate.h
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

#import <Cocoa/Cocoa.h>

@class AssetsWindowController;          //Assets Window
@class PreferencesWindowController;     //Preferences Window
@class SplashWindowController;

/*!
 * @class       AppDelegate:
 * @abstract    Responsible for all the OS interaction, for short.
 * @discussion  This is the main class of this project. Maybe in the future I
 *              will transfer the main functionality of the data handling to a
 *              new class. But lets keep it simple until we need that.
 */
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    //--------------------------------------------------------------------------    
    // Grand Central Dispatch

    dispatch_queue_t queue;
    
    //--------------------------------------------------------------------------
    // Array Controllers
    
    IBOutlet NSArrayController  * virtualMachinesArrayController;
    IBOutlet NSArrayController  * romFilesController;
    IBOutlet NSScrollView       * virtualMachinesList;
    
    //--------------------------------------------------------------------------
    // Sheets
    
    //New VM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPanel            * newMachineView;
    IBOutlet NSTextField        * newMachineNameField;
    IBOutlet NSTextField        * newMachineErrorLabel;
    
    //Clone VM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPanel            * cloneMachineView;
    IBOutlet NSTextField        * cloneMachineNameField;
    IBOutlet NSTextField        * cloneMachineErrorLabel;
    
    //Delete VM - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPanel            * deleteMachineView;
    
    //Error  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    IBOutlet NSPanel            * errorSheetView;
    IBOutlet NSTextField        * errorSheetLabel;
    
    //--------------------------------------------------------------------------
    //Controllers

    // Window Controllers:

    AssetsWindowController      * assetsWindowController;
    PreferencesWindowController * preferencesWindowController;
    SplashWindowController      * splashWindowController;
    
    NSMutableDictionary * windowsForVirtualMachines;
    
    /// 32-bit compatibility -------    
    id _window;
    id __persistentStoreCoordinator;
    id __managedObjectModel;
    id __managedObjectContext;
    /// ----------------------------
}

//------------------------------------------------------------------------------
// Default properties ahead.

@property (assign) IBOutlet NSWindow * window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext * managedObjectContext;

//------------------------------------------------------------------------------
// Default methods ahead.

- (IBAction)saveAction:(id)sender; //don't know! Saves the managed object context. But why?

//------------------------------------------------------------------------------
// New methods ahead.

// Buttons
// Actions to the buttons that create and delete VM entries in the coredata.

- (IBAction)saveNewVirtualMachine:(id)sender;
- (IBAction)saveCloneVirtualMachine:(id)sender;
- (IBAction)deleteVirtualMachine:(id)sender;
- (void)selectLastCreatedVirtualMachine:(id)sender;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Windows

- (IBAction)showMainWindow:(id)sender;

- (IBAction)openVirtualMachineWindow:(id)sender;
// Opens the virtual machine's properties.

- (IBAction)showAssetsWindow:(id)sender;
// Action to show the Assets Window.

- (IBAction)showPreferencesWindow:(id)sender;
// Action to show the Preferences Window.

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Sheets

// Open all sheets:
- (IBAction)showNewMachineView:(id)sender;
- (IBAction)showCloneMachineView:(id)sender;
- (IBAction)showDeleteMachineView:(id)sender;
- (IBAction)showErrorSheetView:(id)sender;

// Close all sheets:
- (IBAction)endNewMachineView:(id)sender;
- (IBAction)endCloneMachineView:(id)sender;
- (IBAction)endDeleteMachineView:(id)sender;
- (IBAction)endErrorSheetView:(id)sender;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Utilities

- (NSString *)applicationSupportDirectory;
- (void)saveCoreData;
//- (void)releaseWindowFor:(NSString *)virtualMachineUniqueName;

@end
