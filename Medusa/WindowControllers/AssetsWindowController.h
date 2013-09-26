//
//  AssetsWindowController.h
//  Medusa
//
//  Created by Giancarlo Mariot on 30/06/2012.
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

@interface AssetsWindowController : NSWindowController {
    
    //Standard variables
    NSManagedObjectContext  * managedObjectContext;    
    NSMutableArray          * menuObjectsArray;
    
    //Interface objects
    IBOutlet NSToolbar         * assetsToolbar;
//    IBOutlet NSTableView    * detailsTree;
    IBOutlet NSView            * placeholderView;
    IBOutlet NSView            * subViewDropFiles;
    IBOutlet NSView            * subViewRomFiles;
    IBOutlet NSView            * subViewDisks;
    IBOutlet NSView            * subViewEmulators;
    IBOutlet NSArrayController * RomFilesArrayController;
}

//------------------------------------------------------------------------------
// Manual getters
- (NSManagedObjectContext *)managedObjectContext;

// Manual setters
- (void)setManagedObjectContext:(NSManagedObjectContext *)value;

// Init methods
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext;

//------------------------------------------------------------------------------
//- (IBAction)traceTableViewClick:(id)sender;

- (IBAction)displayDropFilesView:(id)sender;
- (IBAction)displayRomFilesView:(id)sender;
- (IBAction)displayDisksView:(id)sender;
- (IBAction)displayEmulatorsView:(id)sender;

- (IBAction)scanEmulators:(id)sender;

@end
