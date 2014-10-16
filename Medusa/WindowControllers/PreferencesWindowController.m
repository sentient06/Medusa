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
#import "FileManager.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation PreferencesWindowController

@synthesize contentSubview = _contentSubview;

//------------------------------------------------------------------------------
// Dealloc and initialization

#pragma mark – Dealloc and initialization

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [_contentSubview release];
    [super dealloc];
}

///**
// * Try to update open windows when closing....
// */
//- (void)windowWillClose:(NSNotification *)notification {
//    DDLogVerbose(@"preferences's window will close");
//    [[NSApp delegate] updateVMWindows];
//}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        _contentSubview = [[NSView alloc] initWithFrame:[[[self window] contentView] frame]];
    }
    return self;
}

/*!
 * @discussion    Need to load one of the subviews here.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSRect windowFrame = [[[self window] contentView] frame];
    [self.contentSubview setFrame:windowFrame];
    
    [[[self window] contentView] addSubview:self.contentSubview];
    DDLogVerbose(@"subview's frame: %@", NSStringFromRect([self.contentSubview frame]));
    
    ///[primaryView addSubview: generalSubView];
    [preferencesToolbar setSelectedItemIdentifier:@"generalButton"];
    
    //DDLogVerbose(@"%@",[[preferencesToolbar items] objectAtIndex:0]);
    //[[[preferencesToolbar items] objectAtIndex:0] setEnabled:YES];
    
    [self changeWindowSubview:0 animate:NO];
    
}

//-(void)awakeFromNib {
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//        selector:@selector(windowWillClose:)
//            name:NSWindowWillCloseNotification
//          object:self.window
//    ];
//}

//------------------------------------------------------------------------------
// Methods

#pragma mark – Methods

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

/*!
 * @method      changeWindowSubview:animate:
 * @abstract    Changes subviews in the main window.
 */
- (void)changeWindowSubview:(NSInteger)viewIndex animate:(BOOL)animate {
    
    NSView * oldView = nil;
    NSView * newView = nil;

    switch (viewIndex) {
        default:
        case 0:
            newView = generalSubView;
            break;
            
        case 1:
            newView = shareSubView;
            break;
            
        case 2:
            newView = advancedSubView;
            break;

    }
    
    //--------------------------------------------------------------------------
    // Get a list of all of the views in the window. Usually at this
    // point there is just one visible view. But if the last fade
    // hasn't finished, we need to get rid of it now before we move on.
    
    if([[self.contentSubview subviews] count] > 0) {
        
        NSEnumerator *subviewsEnum = [[self.contentSubview subviews] reverseObjectEnumerator];
        
        // The first one (last one added) is our visible view.
        oldView = [subviewsEnum nextObject];
        
        // Remove any others.
        NSView *reallyOldView = nil;
        while((reallyOldView = [subviewsEnum nextObject]) != nil){
            [reallyOldView removeFromSuperviewWithoutNeedingDisplay];
        }
    }
    
    //--------------------------------------------------------------------------
    
    //Remove old views.
    //Insert new view.
    
    if(![newView isEqualTo:oldView]){
        
        [oldView removeFromSuperviewWithoutNeedingDisplay];
        [newView setHidden:NO];
        
        NSRect subFrame = [self frameForView:newView];
        
        [self.contentSubview setFrameSize:subFrame.size];   //Resizes subview.       
        [self.contentSubview addSubview:newView];           //Adds subview into subview.
        [[self window] setInitialFirstResponder:newView];
        
        [[self window] setFrame:subFrame display:YES animate:animate];
        
    }
    
}


/*!
 * @method      frameForView:
 * @abstract    Retrieves frame information from view.
 * @return      NSRect (with size and origin) from view.
 */
- (NSRect)frameForView:(NSView *)view {
    
	NSRect windowFrame = [[self window] frame];
	NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
	float windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
    
	windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
	windowFrame.size.width = NSWidth([view frame]);
	windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
	
	return windowFrame;
}

- (IBAction)deleteXPRAM:(id)sender {
    DDLogInfo(@"XPRAM triggered");
    [FileManager deleteXPRAMFile];
}

- (IBAction)updateVirtualMachines:(id)sender {
    [[NSApp delegate] updateVMWindows];
}

//------------------------------------------------------------------------------
// Interface actions

#pragma mark – Interface actions

/*!
 * @method      openSubView:
 * @abstract    Displays a subview in the main window.
 */
- (IBAction)openSubView:(id)sender {
    
    [self changeWindowSubview: [sender tag] animate:YES];
    /*
    
    [[[primaryView subviews] objectAtIndex:0] removeFromSuperview];
    
    switch ([sender tag]) {
        default:
        case 0:
            [primaryView addSubview: generalSubView];
            break;
            
        case 1:
            [primaryView addSubview: shareSubView];
            break;
            
        case 2:
            [primaryView addSubview: advancedSubView];
            break;
            
        case 3:
            [primaryView addSubview: developerSubView];
            break;
            
    }
     */
    
}

///*!
// * @method      openBasiliskPath:
// * @abstract    Displays the open dialog to find Basilisk II executable.
// */
//- (IBAction)openBasiliskPath:(id)sender {
//    
//    //Array of accepted file types:
//    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
//    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
//    
//    if ([filePath count] == 1) {
//        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"BasiliskPath"];
//    }
//    
//}

///*!
// * @method      openBasiliskPath:
// * @abstract    Displays the open dialog to find Sheepshaver executable.
// */
//- (IBAction)openSheepshaverPath:(id)sender {
//    
//    //Array of accepted file types:
//    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
//    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
//    
//    if ([filePath count] == 1) {
//        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"SheepshaverPath"];
//    }
//    
//}

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

@end
