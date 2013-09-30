//
//  AssetsWindowController.m
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

#import "AssetsWindowController.h"
#import "TableLineInformationController.h"
#import "AppDelegate.h"
#import "EmulatorModel.h"

@implementation AssetsWindowController

//------------------------------------------------------------------------------
// Manual getters

/*!
 * @method      managedObjectContext:
 * @abstract    Manual getter.
 */
- (NSManagedObjectContext *)managedObjectContext {
    return managedObjectContext;
}

// Manual setters

/*!
 * @method      setManagedObjectContext:
 * @abstract    Manual setter.
 */
- (void)setManagedObjectContext:(NSManagedObjectContext *)value {
    managedObjectContext = value;
}

//------------------------------------------------------------------------------
// Methods.

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [managedObjectContext release];
    [menuObjectsArray release];
    
    [super dealloc];
}

// Init methods

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {

    self = [super initWithWindowNibName:@"AssetsWindow"];
    
    if (self) {
        [self setManagedObjectContext: theManagedObjectContext];
    }
    
    return self;
}

- (IBAction)displayDropFilesView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDropFiles];
}

- (IBAction)displayRomFilesView:(id)sender {
    [RomFilesArrayController rearrangeObjects];
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewRomFiles];
}

- (IBAction)displayDisksView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDisks];
}

- (IBAction)displayEmulatorsView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewEmulators];
}

- (IBAction)scanEmulators:(id)sender {
    EmulatorModel * emulatorObject = [[EmulatorModel alloc] init];
    [emulatorObject scanEmulators];
    [emulatorObject release];
}

- (id)initWithWindow:(NSWindow *)window {
    
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //----------------------------------------------------------
    //Interface view
    
    NSSortDescriptor * romSorting = [[[NSSortDescriptor alloc]
                                      initWithKey:@"modelName" ascending:YES] autorelease];
    [RomFilesArrayController setSortDescriptors:[NSArray arrayWithObject: romSorting]];
    
    [placeholderView addSubview: subViewDropFiles];
    [assetsToolbar setSelectedItemIdentifier:@"dropFilesButton"];
}

@end
