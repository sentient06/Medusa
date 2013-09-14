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

//    BOOL displayAllTabs = [[NSUserDefaults standardUserDefaults] boolForKey:@"displayAllTabs"];
    
    
    //----------------------------------------------------------
    //Interface view
    
    self = [super initWithWindowNibName:@"AssetsWindow"];
    
    if (self) {
        
//        TableLineInformationController * romFiles = [
//            [TableLineInformationController alloc]                
//            initWithTitle:@"Rom files"
//                  andIcon:@"RomFile.icns"
//        ];
//
//        TableLineInformationController * disks = [
//            [TableLineInformationController alloc]                
//            initWithTitle:@"Disks"
//                  andIcon:@"Drive.icns"
//        ];
//        
//        menuObjectsArray = [
//            [NSMutableArray alloc]
//            initWithObjects: romFiles, nil
//        ];
//        
//        if (displayAllTabs == YES) {
//            [menuObjectsArray addObject: disks];
//        }
//        
//        [disks release];
//        [romFiles release];
        
    }
    
    [self setManagedObjectContext: theManagedObjectContext];
    
    //----------------------------------------------------------
    //Interface subviews
    
    // -- Share tab
    
    //Handle the status of the open path button in the share area:
    
//    BOOL enabledShare = [[virtualMachine shareEnabled] boolValue] == YES;
//    BOOL shareDefault = [[virtualMachine useDefaultShare] boolValue] == YES;
//    
//    if ( enabledShare &  shareDefault ) {          
//        currentPathOption = useStandardPathOption;
//    }else if ( enabledShare & !shareDefault ) {
//        currentPathOption = usePersonalPathOption;
//    }else if ( !enabledShare & !shareDefault ) {
//        currentPathOption = useNoSharedPathOption;
//    }
    
    //----------------------------------------------------------
    
    return self;

}

/*!
 * @method      traceTableViewClick:
 * @abstract    Changes the right pane according to the selected item in the
 *              left pane menu.
 * @discussion  Just checks the row and shows content accordinly.
 */
- (IBAction)traceTableViewClick:(id)sender {
    
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    
    switch ([detailsTree selectedRow]) {
        default:
        case 0:
            [placeholderView addSubview: subViewRomFiles];
            break;
            
        case 1:
            [placeholderView addSubview: subViewDisks];
            break;
    }
    
}

- (IBAction)displayDropFilesView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDropFiles];
}

- (IBAction)displayRomFilesView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewRomFiles];
}

- (IBAction)displayDisksView:(id)sender {
    [[[placeholderView subviews] objectAtIndex:0] removeFromSuperview];
    [placeholderView addSubview: subViewDisks];
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
    
    [placeholderView addSubview: subViewDropFiles];
    [assetsToolbar setSelectedItemIdentifier:@"dropFilesButton"];
}

@end
