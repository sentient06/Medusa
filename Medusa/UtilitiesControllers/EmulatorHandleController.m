//
//  EmulatorHandleController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 19/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "EmulatorHandleController.h"

@implementation EmulatorHandleController

+(void)executeBasiliskII:(id)preferencesFilePath {

    NSString * emulatorPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"Emulators/Basilisk II" ]];
    
    // Starts emulator:
    
    NSTask * emulatorTask = [[NSTask alloc] init];
    [emulatorTask setLaunchPath:emulatorPath];
    [emulatorTask setArguments:
        [NSArray arrayWithObjects:
             @"--config"
           , preferencesFilePath
           ,nil
        ]
    ];
    
    [emulatorTask launch];
    [emulatorTask waitUntilExit];
    [emulatorTask release];
    [emulatorPath release];
    
}

@end
