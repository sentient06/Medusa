//
//  EmulatorModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
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

#import "EmulatorModel.h"
#import "EmulatorsEntityModel.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_ERROR;
//------------------------------------------------------------------------------

@implementation EmulatorModel

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [emulatorsDirectory release];
    [super dealloc];
}

/*!
 * @method      scanEmulators:
 * @abstract    Scans for emulators inside app support dir.
 */
- (void)scanEmulators {

    BOOL isDir;

    NSFileManager * fileManager= [NSFileManager defaultManager];

    if(![fileManager fileExistsAtPath:emulatorsDirectory isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:emulatorsDirectory withIntermediateDirectories:YES attributes:nil error:NULL])
            DDLogError(@"Error: Could not create folder %@", emulatorsDirectory);

    } else {
        [self scanEmulatorFamily:basiliskFamily];
    }
    
    if (mustSave) [[NSApp delegate] saveCoreData];
}

/*!
 * @method      scanEmulatorFamily:
 * @abstract    Scans for a given emulator inside the app support emulator dir.
 */
- (void)scanEmulatorFamily:(int)emulatorFamily {

    NSString * emulatorName;
    NSString * emulatorDir;
    
    switch (emulatorFamily) {
        case miniVMacFamily:
            emulatorName = [[NSString alloc] initWithString:@"vMac"];
            emulatorDir = [[NSString alloc] initWithFormat:@"%@/vMac", emulatorsDirectory];
            break;

        case basiliskFamily:
            emulatorName = [[NSString alloc] initWithString:@"Basilisk II"];
            emulatorDir = [[NSString alloc] initWithFormat:@"%@/Basilisk", emulatorsDirectory];
            break;
        
        case sheepshaverFamily:
            emulatorName = [[NSString alloc] initWithString:@"Sheepshaver"];
            emulatorDir = [[NSString alloc] initWithFormat:@"%@/Sheepshaver", emulatorsDirectory];
            break;
        default:
            DDLogError(@"Error: unknown emulator family.");
            return;
            break;
    }
    
    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    BOOL emulatorFolderIsDir;

    if(![fileManager fileExistsAtPath:emulatorDir isDirectory:&emulatorFolderIsDir]) {
        if(![fileManager createDirectoryAtPath:emulatorDir withIntermediateDirectories:YES attributes:nil error:NULL]) {
            DDLogError(@"Error: Could not create folder %@", emulatorDir);
        }
        return;
    }
    
    NSMutableArray * shallowDirectoryList =[[NSMutableArray alloc]
        initWithArray:[fileManager contentsOfDirectoryAtPath:emulatorDir error:nil]
    ];
    
    if([shallowDirectoryList containsObject:@".DS_Store"])
        [shallowDirectoryList removeObject:@".DS_Store"];
    
    if ([shallowDirectoryList count] < 1) return;

    NSString * contentsSuffix = [[NSString alloc] initWithFormat:@"%@.app/Contents", emulatorName];
    
    for (NSString * folder in shallowDirectoryList) {

        NSString * currentEmulatorFolder = [[NSString alloc] initWithFormat:@"%@/%@", emulatorDir, folder];
        BOOL currentEmulatorFolderIsDir;
        BOOL currentEmulatorFolderExists = [fileManager fileExistsAtPath:currentEmulatorFolder isDirectory:&currentEmulatorFolderIsDir];
        
        if (!currentEmulatorFolderExists) {
            DDLogError(@"Error: folder doesn't exist:\n%@", currentEmulatorFolder);
            return;
        }
        if (!currentEmulatorFolderIsDir){
            DDLogError(@"Error: folder is not a folder!\n%@", currentEmulatorFolder);
            return;
        }
        
        DDLogVerbose(@"Exists: %@", currentEmulatorFolder);
        
        NSString * currentEmulatorPListFile = [[NSString alloc] initWithFormat:@"%@/%@/Info.plist", currentEmulatorFolder, contentsSuffix];
        BOOL currentEmulatorPListFileIsDir;
        BOOL currentEmulatorPListFileExists = [fileManager
            fileExistsAtPath:currentEmulatorPListFile
                 isDirectory:&currentEmulatorPListFileIsDir
        ];
        
        if (currentEmulatorPListFileExists && !currentEmulatorPListFileIsDir) {
            NSMutableDictionary * plist = [[NSMutableDictionary alloc]
                initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:currentEmulatorPListFile]
            ];
            
            NSString * executableName = [[NSString alloc] initWithString:[plist valueForKey:@"CFBundleExecutable"]];
            NSString * versionString  = [[NSString alloc] initWithString:[plist valueForKey:@"CFBundleShortVersionString"]];
            
            if (executableName) {
                NSString * currentEmulatorUnixFile = [[NSString alloc] initWithFormat:@"%@/%@/MacOS/%@", currentEmulatorFolder, contentsSuffix, executableName];
                
                BOOL currentEmulatorExeFileIsDir;
                BOOL currentEmulatorExeFileExists = [fileManager
                    fileExistsAtPath:currentEmulatorUnixFile
                         isDirectory:&currentEmulatorPListFileIsDir
                ];
                
                if (!currentEmulatorExeFileExists){
                    DDLogError(@"Error: Exe doesn't exist!\n%@", currentEmulatorUnixFile);
                    return;
                }

                if (currentEmulatorExeFileIsDir) {
                    DDLogError(@"Error: Exe file is... a folder!?\n%@", currentEmulatorUnixFile);
                    return;
                }
                    
                DDLogVerbose(@"Name: %@, Version: %@, Unix file: %@", folder, versionString, currentEmulatorUnixFile);
                
                //----------------------------------------------------------------------
                // Core-data part:
                
                NSError * errorFetch;
                
                NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
                NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"Emulators" inManagedObjectContext:managedObjectContext];
                NSPredicate         * predicate = [ NSPredicate
                    predicateWithFormat: @"unixPath = %@"
                    , currentEmulatorUnixFile
                ];
                
                [request setEntity:entity];
                [request setPredicate: predicate];

                NSInteger resultCount = [managedObjectContext countForFetchRequest:request error:&errorFetch];
                
                [request release];
                
                if (resultCount > 0) {
                    DDLogVerbose(@"This Emulator app is duplicated!");
                } else {
                    
                    //Sets a new emulator object.
                    EmulatorsEntityModel * newEmulatorObject = [
                        NSEntityDescription
                        insertNewObjectForEntityForName:@"Emulators"
                                 inManagedObjectContext:managedObjectContext
                    ];
                    
                    //Here we have all the fields to be inserted.
                    [newEmulatorObject setFamily:[NSNumber numberWithInt:emulatorFamily]];
                    [newEmulatorObject setName:[NSString stringWithFormat:@"%@ v%@ [M]", emulatorName, versionString]];
                    [newEmulatorObject setMaintained:[NSNumber numberWithBool:YES]];
                    [newEmulatorObject setUnixPath:currentEmulatorUnixFile];
                    [newEmulatorObject setVersion:versionString];
                    
                    mustSave = YES;
                    
                }

                [currentEmulatorUnixFile release];
                [plist release];
                
            }
            
            [versionString release];
            [executableName release];
        }
        
        [currentEmulatorPListFile release];

        
        [currentEmulatorFolder release];
    }

    [contentsSuffix release];    
    [shallowDirectoryList release];

}

/*!
 * @method      init
 * @abstract    Init method.
 */
- (id)init {
    self = [super init];
    if (self) {
        mustSave = NO;
        emulatorsDirectory = [[NSString alloc] initWithFormat:@"%@/Emulators", [[NSApp delegate] applicationSupportDirectory]];      
    }
    return self;
}

@end
