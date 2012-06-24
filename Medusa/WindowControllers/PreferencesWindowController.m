//
//  PreferencesWindowController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 26/05/2012.
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

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController

//------------------------------------------------------------------------------
// Methods.

/*!
 * @method      openDialogForExtensions:
 * @abstract    Displays the open dialog.
 * @return      Array of files selected.
 */
- (NSArray*)openDialogForExtensions:(NSArray *)extensions {
    
    NSArray * selectedFiles = [[[NSArray alloc] init] autorelease];
    
    NSOpenPanel * openDialog = [NSOpenPanel openPanel]; //File open dialog class.
    
    //Dialog options:
    [openDialog setCanChooseFiles:YES];
    [openDialog setAllowedFileTypes:extensions];
    [openDialog setAllowsMultipleSelection:NO];
    
    //Display it and trace OK button:
    if ([openDialog runModal] == NSOKButton) {
        selectedFiles = [openDialog URLs];        
    }
    
    return selectedFiles;
    
}

//------------------------------------------------------------------------------

/*!
 * @method      openSubView:
 * @abstract    Displays a subview in the main window.
 */
- (IBAction)openSubView:(id)sender {
    
    [[[primaryView subviews] objectAtIndex:0] removeFromSuperview];
    
    switch ([sender tag]) {
        default:
        case 0:
            [primaryView addSubview: generalSubView];
            break;
            
        case 1:
            [primaryView addSubview: shareSubView];
            break;
            
    }
    
}

/*!
 * @method      openBasiliskPath:
 * @abstract    Displays the open dialog to find Basilisk II executable.
 */
- (IBAction)openBasiliskPath:(id)sender {
    
    //Array of accepted file types:
    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
    
    if ([filePath count] == 1) {
        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"BasiliskPath"];
    }
    
}

/*!
 * @method      openBasiliskPath:
 * @abstract    Displays the open dialog to find Sheepshaver executable.
 */
- (IBAction)openSheepshaverPath:(id)sender {
    
    //Array of accepted file types:
    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
    
    if ([filePath count] == 1) {
        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"SheepshaverPath"];
    }
    
}

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
        [[NSUserDefaults standardUserDefaults] setURL:[selectedFiles objectAtIndex:0] forKey:@"StandardSharePath"];
    }
    
}

//------------------------------------------------------------------------------
// Standard methods.

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*!
 * @discussion    Need to load one of the subviews here.
 */
- (void)windowDidLoad {
    [super windowDidLoad];    
    [primaryView addSubview: generalSubView];
    //NSLog(@"%@",[[preferencesToolbar items] objectAtIndex:0]);
    //[[[preferencesToolbar items] objectAtIndex:0] setEnabled:YES];
}

//------------------------------------------------------------------------------

@end
