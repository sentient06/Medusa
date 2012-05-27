//
//  PreferencesWindowController.h
//  Medusa
//
//  Created by Giancarlo Mariot on 26/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController {
    IBOutlet NSTextField *basiliskPathTextField;
    IBOutlet NSTextField *basiliskPreferencesPathTextField;
}


- (NSArray*)openDialogForExtensions:(NSArray*)extensions;

- (IBAction)openBasiliskPath:(id)sender;
- (IBAction)openBasiliskPreferencesPath:(id)sender;
- (IBAction)openSheepshaverPath:(id)sender;
- (IBAction)openSheepshaverPreferencesPath:(id)sender;

@end
