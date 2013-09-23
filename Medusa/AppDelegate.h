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
//@class RomManagerWindowController;      //Rom Manager Window
//@class DriveManagerWindowController;    //Drive Manager Window
@class AssetsWindowController;          //Assets Window
@class PreferencesWindowController;     //Preferences Window
@class SplashWindowController;

//typedef enum Emulator {
//    vMac,
//    BasiliskII,
//    Sheepshaver
//} Emulator;

/*!
 * @class       AppDelegate:
 * @abstract    Responsible for all the OS interaction, for short.
 * @discussion  This is the main class of this project. Maybe in the future I
 *              will transfer the main functionality of the data handling to a
 *              new class. But lets keep it simple until we need that.
 */
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    // Grand Central Dispatch queue  - - - - - - - - - - - - - - - - - - - - - -
    dispatch_queue_t queue;
    
    // Array Controllers - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
    IBOutlet NSArrayController  * virtualMachinesArrayController;
    //Array controller to keep track of the machines list.
    IBOutlet NSArrayController  * romFilesController;
    //Array controller with the rom file.
    
    IBOutlet NSScrollView * virtualMachinesList;
    
    //New VM Sheet - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPanel            * newMachineView;
    //Sheet used to create a new machine.
    IBOutlet NSTextField        * newMachineNameField;
    //Text field in the new machine sheet.
    IBOutlet NSPopUpButton      * newMachineModelField;
    //Pop up button with the model (rom file).
    IBOutlet NSMatrix           * newMachineModelRadio;
    
    //Clone VM Sheet - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSPanel            * cloneMachineView;
    //Sheet used to create a new machine.
    IBOutlet NSTextField        * cloneMachineNameField;
    //Text field in the new machine sheet.
    
    //Window Controllers:
    AssetsWindowController          * assetsWindowController;
    PreferencesWindowController     * preferencesWindowController;
    SplashWindowController          * splashWindowController;
    
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

- (IBAction)saveNewVirtualMachine:(id)sender;
//Action to the button that creates the new entry in the coredata.

- (IBAction)openVirtualMachineWindow:(id)sender;
//Opens the iTunes-like window to control the machine's properties.

- (IBAction)showAssetsWindow:(id)sender;
//Action to show the Assets Window.

- (IBAction)showPreferencesWindow:(id)sender;
//Action to show the Preferences Window.

- (NSString *)applicationSupportDirectory;

@end
