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
#import "ASIHTTPRequest.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

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

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [downloadDirectory release];
    [managedObjectContext release];
    [menuObjectsArray release];
    [super dealloc];
}

//------------------------------------------------------------------------------
// Application methods.

#pragma mark – Main Window actions

/*!
 * @method      displayDropFilesView:
 * @discussion  Displays the drop files subview.
 *              If the sender is not one of the toolbar buttons, it sets the
 *              button to selected.
 */
- (IBAction)displayDropFilesView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDropFiles];
    if (![sender isKindOfClass:[NSToolbarItem class]])
        [assetsToolbar setSelectedItemIdentifier:@"dropFilesButton"];
}

/*!
 * @method      displayRomFilesView:
 * @discussion  Displays ROM image files management subview.
 *              If the sender is not one of the toolbar buttons, it sets the
 *              button to selected.
 */
- (IBAction)displayRomFilesView:(id)sender {
    [RomFilesArrayController rearrangeObjects];
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewRomFiles];
    if (![sender isKindOfClass:[NSToolbarItem class]])
        [assetsToolbar setSelectedItemIdentifier:@"dropRomsButton"];
}

/*!
 * @method      displayDisksView:
 * @discussion  Displays Disk files management subview.
 *              If the sender is not one of the toolbar buttons, it sets the
 *              button to selected.
 */
- (IBAction)displayDisksView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDisks];
    if (![sender isKindOfClass:[NSToolbarItem class]])
        [assetsToolbar setSelectedItemIdentifier:@"dropDisksButton"];
}

/*!
 * @method      displayEmulatorsView:
 * @discussion  Displays Emulator management subview.
 *              If the sender is not one of the toolbar buttons, it sets the
 *              button to selected.
 */
- (IBAction)displayEmulatorsView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewEmulators];    
    if (![sender isKindOfClass:[NSToolbarItem class]])
        [assetsToolbar setSelectedItemIdentifier:@"dropEmulatorsButton"];
}

/*!
 * @method      scanEmulators:
 * @discussion  Scans for emulators in Application Support folder.
 */
- (IBAction)scanEmulators:(id)sender {
    EmulatorModel * emulatorObject = [[EmulatorModel alloc] init];
    [emulatorObject scanEmulators];
    [emulatorObject release];
}

/*!
 * @method      showDownloadPanel:
 * @abstract    Displays the basilisk download sheet.
 */
- (IBAction)showDownloadPanel:(id)sender {
    [ NSApp
            beginSheet: downloadPanel
        modalForWindow: [self window]
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      cancelDownloadEmulators:
 * @abstract    Closes the basilisk download sheet.
 */
- (IBAction)cancelDownloadEmulators:(id)sender {
    [request cancel];
    [NSApp endSheet:downloadPanel];
    [downloadPanel orderOut:sender];
}

/*!
 * @method      downloadEmulators:
 * @discussion  Downloads emulators to Application Support folder.
 */
- (IBAction)downloadEmulators:(id)sender {
    
    NSLog(@"Temp dir: %@", downloadDirectory);
    
    NSURL * url = [NSURL URLWithString:@"http://127.0.0.1/BasiliskExecutables.zip"];
    
    request = [ASIHTTPRequest requestWithURL:url];
    
    [request setDownloadProgressDelegate:downloadProgressIndicator];
    [request setDownloadDestinationPath:[downloadDirectory stringByAppendingPathComponent:@"BasiliskExecutables.zip"]];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

//------------------------------------------------------------------------------
// Utility methods

#pragma mark – Utility

- (void)requestFinished:(ASIHTTPRequest *)thisRequest {
    NSLog(@"finished");
//    // Use when fetching text data
//    NSString *responseString = [request responseString];
//    
//    // Use when fetching binary data
//    NSData *responseData = [request responseData];
    
    [NSApp endSheet:downloadPanel];
    [downloadPanel orderOut:nil];
    
    EmulatorModel * emulatorObject = [[EmulatorModel alloc] init];
    [emulatorObject assembleEmulatorsFromZip:[NSString stringWithFormat:@"%@%@", downloadDirectory, @"BasiliskExecutables"]];
    [emulatorObject release];


}

- (void)requestFailed:(ASIHTTPRequest *)thisRequest {
    NSError * error = [thisRequest error];
    DDLogError(@"Request failed: %@", error);
    [NSApp endSheet:downloadPanel];
    [downloadPanel orderOut:nil];
}

//------------------------------------------------------------------------------
// Init methods

#pragma mark – Init

/*!
 * @method      initWithManagedObjectContext:
 * @discussion  Initiates with a managed object context by default.
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theManagedObjectContext {
    self = [super initWithWindowNibName:@"AssetsWindow"];
    if (self) {
        [self setManagedObjectContext: theManagedObjectContext];
        downloadDirectory = [[NSString alloc] initWithString:NSTemporaryDirectory()];
    }
    return self;
}

/*!
 * @method      initWithWindow:
 * @discussion  Default for NSWindowController classes.
 */
- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        downloadDirectory = [[NSString alloc] initWithString:NSTemporaryDirectory()];
    }
    return self;
}

/*!
 * @method      windowDidLoad:
 * @discussion  Actions to be taken when window is already loaded.
 *              Default for NSWindowController classes.
 */
- (void)windowDidLoad {

    [super windowDidLoad];
    
    //----------------------------------------------------------
    //Interface view
    
    NSSortDescriptor * romSorting = [[[NSSortDescriptor alloc] initWithKey:@"modelName" ascending:YES] autorelease];
    [RomFilesArrayController setSortDescriptors:[NSArray arrayWithObject: romSorting]];
    [placeholderView addSubview: subViewDropFiles];
    [assetsToolbar setSelectedItemIdentifier:@"dropFilesButton"];

}

@end
