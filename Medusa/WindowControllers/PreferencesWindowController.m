//
//  PreferencesWindowController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 26/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//-------

- (NSArray*)openDialogForExtensions:(NSArray *)extensions {
    
    NSArray * selectedFiles = [[[NSArray alloc] init] autorelease];
    
    //int i; //Loop counter.
    NSOpenPanel * openDialog = [NSOpenPanel openPanel]; //File open dialog class.
    
    //Dialog options:
    [openDialog setCanChooseFiles:YES];
    [openDialog setAllowedFileTypes:extensions];
    [openDialog setAllowsMultipleSelection:NO];
    
    //Display it and trace OK button:
    if ([openDialog runModal] == NSOKButton) {
        selectedFiles = [openDialog URLs];
//        return [openDialog URLs];
        //for (i = 0; i < [selectedFiles count]; i++) {
        //    NSLog(@"File path: %@", [[selectedFiles objectAtIndex:i] path]);
        //}
        
    }
    
    return selectedFiles;
    
}

- (IBAction)openBasiliskPath:(id)sender {
    
    //Array of accepted file types:
    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
    
    if ([filePath count] == 1) {
        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"BasiliskPath"];
    }
    
}
- (IBAction)openBasiliskPreferencesPath:(id)sender {
    
}
- (IBAction)openSheepshaverPath:(id)sender {
    
    //Array of accepted file types:
    NSArray * fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
    NSArray * filePath = [self openDialogForExtensions:fileTypesArray];
    
    if ([filePath count] == 1) {
        [[NSUserDefaults standardUserDefaults] setURL:[filePath objectAtIndex:0] forKey:@"SheepshaverPath"];
    }
    
}
- (IBAction)openSheepshaverPreferencesPath:(id)sender {
    
}

@end
