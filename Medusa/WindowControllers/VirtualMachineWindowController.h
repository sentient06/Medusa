//
//  VirtualMachineWindowController.h
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

typedef enum {
    useStandardPathOption = 0,
    usePersonalPathOption,
    useNoSharedPathOption
} pathOptions;

@class VirtualMachinesModel, DropRomView;

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
    NSManagedObjectContext  * managedObjectContext;
    
    NSMutableArray          * menuObjectsArray;
    NSMutableArray          * subviewsArray;
    
    NSString                * windowTitle;
    
    //Interface objects
    
    IBOutlet NSToolbar * settingsToolbar;
    
    IBOutlet NSView         * placeholderView;
    IBOutlet NSView         * subViewConfiguration;
    IBOutlet NSView         * subViewDisplay;
    IBOutlet NSView         * subViewDrives;
    IBOutlet NSView         * subViewSharing;
    IBOutlet NSView         * subViewAdvanced;
    
    //Controllers
    IBOutlet NSArrayController * availableDisksController;
    IBOutlet NSArrayController * usedDisksController;
    IBOutlet NSArrayController * romFilesController;
    
    // Share subview - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    IBOutlet NSMatrix    * sharedPathMatrix;
    IBOutlet NSButton    * openSharePathButton;
    IBOutlet NSTextField * sharePathLabel;
//    NSArray  *subViews;    
    
    /// 32-bit compatibility -------    
    pathOptions currentPathOption;
    /// ----------------------------
}
//------------------------------------------------------------------------------
// Standard variables properties.
@property (copy) NSMutableArray *menuObjectsArray;

//------------------------------------------------------------------------------
// Application properties.
@property (copy) NSString * windowTitle;
@property pathOptions currentPathOption;
@property (assign) VirtualMachinesModel * virtualMachine;

//------------------------------------------------------------------------------
// Manual getters
- (NSManagedObjectContext *)managedObjectContext;
- (VirtualMachinesModel *)virtualMachine;

// Manual setters
- (void)setManagedObjectContext:(NSManagedObjectContext *)value;
- (void)setVirtualMachine:(VirtualMachinesModel *)value;

// Init methods
- (id)initWithVirtualMachine:(VirtualMachinesModel *)aVirtualMachine
      inManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;

//------------------------------------------------------------------------------
// General Methods

- (void)savePreferences;

//------------------------------------------------------------------------------
// Interface Methods

// View actions
- (IBAction)changeRightView:(id)sender;
- (IBAction)savePreferencesFromView:(id)sender;
//- (IBAction)traceTableViewClick:(id)sender;
- (IBAction)useSelectedDisks:(id)sender;
- (IBAction)makeDriveBootable:(id)sender;
- (IBAction)deleteUsedDrive:(id)sender;
- (void)resetDriveOrder;
- (IBAction)run:(id)sender;

- (IBAction)displayGeneralView:(id)sender;
- (IBAction)displayDisksView:(id)sender;
- (IBAction)displayDisplayView:(id)sender;
- (IBAction)displayShareView:(id)sender;
- (IBAction)displayAdvancedView:(id)sender;

// Share subview - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/// Behaviour when a different share method is selected.
- (IBAction)changeShareType:(id)sender;

// Open share folder
//- (void)setShareCondition:(NSInteger)condition;
- (IBAction)openSharePath:(id)sender;
- (IBAction)openRomPath:(id)sender;

@end
