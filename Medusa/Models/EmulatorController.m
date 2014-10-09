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

#import "EmulatorController.h"
#import "EmulatorsEntityModel.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation EmulatorController

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

    [[NSApp delegate] saveCoreData];
    
    if(![fileManager fileExistsAtPath:emulatorsDirectory isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:emulatorsDirectory withIntermediateDirectories:YES attributes:nil error:NULL])
            DDLogError(@"Error: Could not create folder %@", emulatorsDirectory);
    } else {
        [self scanEmulatorFamily:basiliskFamily];
        [self scanEmulatorFamily:sheepshaverFamily];
    }

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
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    BOOL emulatorFolderIsDir;

    if(![fileManager fileExistsAtPath:emulatorDir isDirectory:&emulatorFolderIsDir]) {
        if(![fileManager createDirectoryAtPath:emulatorDir withIntermediateDirectories:YES attributes:nil error:NULL]) {
            DDLogError(@"Error: Could not create folder %@", emulatorDir);
        }
        [emulatorName release];
        [emulatorDir release];
        return;
    }
    
    NSMutableArray * shallowDirectoryList = [[NSMutableArray alloc]
        initWithArray:[fileManager contentsOfDirectoryAtPath:emulatorDir error:nil]
    ];
    
    if([shallowDirectoryList containsObject:@".DS_Store"])
        [shallowDirectoryList removeObject:@".DS_Store"];
    
    if ([shallowDirectoryList count] > 0) {
        for (NSString * folder in shallowDirectoryList) {
            [self parseEmulator:[NSString stringWithFormat:@"%@/%@/%@.app", emulatorDir, folder, emulatorName]];
        }
    }

    [[NSApp delegate] saveCoreData];
    [emulatorName release];
    [emulatorDir release];
    [shallowDirectoryList release];
    
}

- (id)parseEmulator:(NSString *)applicationPath {

    int thisEmulatorFamily = undefinedFamily;
    BOOL maintainedByMedusa;
    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    DDLogVerbose(@"Application to parse: %@", applicationPath);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //----------------------------------------------------------------------------
    // Info.plist file parsing

    NSString * currentEmulatorPListFile = [[[NSString alloc] initWithFormat:@"%@/Contents/Info.plist", applicationPath] autorelease];
    BOOL currentEmulatorPListFileIsDir;
    BOOL currentEmulatorPListFileExists = [fileManager
        fileExistsAtPath:currentEmulatorPListFile
             isDirectory:&currentEmulatorPListFileIsDir
    ];
    
    if (!currentEmulatorPListFileExists){
        DDLogError(@"Plist file doesn't exist");
        return nil;
    }
    
    if (currentEmulatorPListFileIsDir){
        DDLogError(@"Weird. Plist file is a folder.");
        return nil;
    }
    
    NSMutableDictionary * plist = [[NSMutableDictionary alloc]
        initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:currentEmulatorPListFile]
    ];

    NSString * executableName = [[[NSString alloc] initWithString:[plist valueForKey:@"CFBundleExecutable"]] autorelease];
    NSString * versionString  = [[[NSString alloc] initWithString:[plist valueForKey:@"CFBundleShortVersionString"]] autorelease];
    NSString * infoString  = [[[NSString alloc] initWithString:[plist valueForKey:@"CFBundleGetInfoString"]] autorelease];
    
    if ([infoString rangeOfString:@"Maintained by Giancarlo Mariot"].location == NSNotFound)
        maintainedByMedusa = NO;
    else
        maintainedByMedusa = YES;
    
    [plist release];

    //----------------------------------------------------------------------------
    // Executable check
    
    if (!executableName) {
        DDLogError(@"There is no reference to a unix executable in the plist file.");
        return nil;
    }

    NSString * currentEmulatorUnixFile = [[[NSString alloc] initWithFormat:@"%@/Contents/MacOS/%@", applicationPath, executableName] autorelease];
    
    BOOL currentEmulatorExeFileIsDir;
    BOOL currentEmulatorExeFileExists = [fileManager
        fileExistsAtPath:currentEmulatorUnixFile
             isDirectory:&currentEmulatorExeFileIsDir
    ];
            
    if (!currentEmulatorExeFileExists){
        DDLogError(@"Error: Unix executable doesn't exist!\n%@", currentEmulatorUnixFile);
        return nil;
    }
    
    if (currentEmulatorExeFileIsDir) {
        DDLogError(@"Error: Unix executable is a folder!\n%@", currentEmulatorUnixFile);
        return nil;
    }
            
    DDLogVerbose(@"Version: %@, Unix file: %@", versionString, currentEmulatorUnixFile);
    
    //----------------------------------------------------------------------------
    // Testing application:
    //
    // execute: ./BasiliskII --config ./
    // exptected response:
    //
    // Basilisk II V1.0 by Christian Bauer et al.
    // ERROR: Cannot open ROM file.
    //
    
    NSTask * emulatorTask = [[NSTask alloc] init];
    NSPipe * emulatorPipe = [[NSPipe alloc] init];
    
    [emulatorTask setStandardOutput:emulatorPipe];
    [emulatorTask setStandardError:emulatorPipe];
    
    [emulatorTask setLaunchPath:currentEmulatorUnixFile];
    [emulatorTask setArguments:
        [NSArray arrayWithObjects:
             @"--config"
           , @"./"
           ,nil
        ]
    ];
    
    [emulatorTask launch];
    [emulatorTask waitUntilExit];
    
    NSData * outputData = [[[emulatorTask standardOutput] fileHandleForReading] availableData];
    
    if ((outputData != nil) && [outputData length]) {

        NSString * outputString = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
        thisEmulatorFamily = basiliskFamily;
        
        if ([outputString rangeOfString:@"Basilisk II"].location == NSNotFound) {
            DDLogVerbose(@"Not Basilisk II.");
            thisEmulatorFamily = sheepshaverFamily;

            if ([outputString rangeOfString:@"SheepShaver"].location == NSNotFound) {
                DDLogVerbose(@"Not Sheepshaver.");
                thisEmulatorFamily = undefinedFamily;

                if ([outputString rangeOfString:@"Christian Bauer"].location == NSNotFound)
                    DDLogVerbose(@"Not Christian Bauer.");

            }
        }

    }
    
    [emulatorTask release];
    [emulatorPipe release];
    
    if (thisEmulatorFamily == undefinedFamily) {
        DDLogWarn(@"Emulator is invalid");
    } else {
        //------------------------------------------------------------------------
        // Checks for core-data duplicates:
                
        NSError * errorFetch;
        
        NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"Emulators" inManagedObjectContext:managedObjectContext];
        NSPredicate         * predicate = [ NSPredicate
            predicateWithFormat: @"unixPath = %@", currentEmulatorUnixFile
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
            [newEmulatorObject setFamily:[NSNumber numberWithInt:thisEmulatorFamily]];

            NSString * nameToBeSet = [[[NSString alloc] init] autorelease];

            if (thisEmulatorFamily == basiliskFamily) {
                nameToBeSet = @"B2";
            }

            if (thisEmulatorFamily == sheepshaverFamily) {
                nameToBeSet = @"SS";
            }

            if ([applicationPath rangeOfString:@"Application Support"].location == NSNotFound) {                
                [newEmulatorObject setName:
                    [NSString stringWithFormat:@"%@ v%@ on %@",
                        nameToBeSet,
                        versionString,
                        [[applicationPath stringByDeletingLastPathComponent] lastPathComponent]]
                ];
            } else {
                [newEmulatorObject setName:[NSString stringWithFormat:@"%@ v%@ on App Support", nameToBeSet, versionString]];
            }

            [newEmulatorObject setMaintained:[NSNumber numberWithBool:maintainedByMedusa]];
            [newEmulatorObject setReadablePath:applicationPath];
            [newEmulatorObject setUnixPath:currentEmulatorUnixFile];
            [newEmulatorObject setVersion:versionString];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"emulatorsUsed"];
            
            return newEmulatorObject;
            
        }
    }
    
    return nil;
    
}

- (void)parseEmulatorsAndSave:(NSArray *)filesList {
    DDLogVerbose(@"%d files to parse...", [filesList count]);
    for (int i = 0; i < [filesList count]; i++) {
        if ([[filesList objectAtIndex:i] respondsToSelector:@selector(path)])
            [self parseEmulator:[[filesList objectAtIndex:i] path]];
        else
            [self parseEmulator:[filesList objectAtIndex:i]];
    }
    [[NSApp delegate] saveCoreData];
}

- (void)assembleEmulatorsFromZip:(NSString *)emulatorsTempDirectory {

    NSTask * unzipTask = [[NSTask alloc] init];
    
    [unzipTask setLaunchPath:@"/usr/bin/unzip"];

    [unzipTask setArguments:
        [NSArray arrayWithObjects:
           @"-o"
           , [NSString stringWithFormat:@"%@.zip", emulatorsTempDirectory]
           , @"-d"
           , [emulatorsTempDirectory stringByDeletingLastPathComponent]
           ,nil
        ]
    ];
    
    [unzipTask launch];
    [unzipTask waitUntilExit];
    [unzipTask release];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSMutableArray * shallowDirectoryList =[[NSMutableArray alloc]
        initWithArray:[fileManager contentsOfDirectoryAtPath:emulatorsTempDirectory error:nil]
    ];
    
    [shallowDirectoryList removeObject:@"BasiliskII.icns"];
    
    for (NSString * folderName in shallowDirectoryList) {
        BOOL success = [self assembleBasiliskInDirectory:emulatorsTempDirectory withName:folderName];
        
        if (success) {
            NSString * originalFolder       = [NSString stringWithFormat:@"%@/%@", emulatorsTempDirectory, folderName];
            NSString * destinyFolderParent  = [NSString stringWithFormat:@"%@/Emulators/Basilisk", [[NSApp delegate] applicationSupportDirectory]];
            NSString * destinyFolder        = [NSString stringWithFormat:@"%@/%@", destinyFolderParent, folderName];
            
            BOOL destinyFolderParentIsDir;
            
            if(![fileManager fileExistsAtPath:destinyFolderParent isDirectory:&destinyFolderParentIsDir])
                if(![fileManager createDirectoryAtPath:destinyFolderParent withIntermediateDirectories:YES attributes:nil error:NULL])
                    DDLogError(@"Error: Could not create folder %@", destinyFolderParent);
            
            DDLogVerbose(@"Destiny: %@", destinyFolder);
            
            if(![fileManager moveItemAtPath:originalFolder toPath:destinyFolder error:NULL]) {
                DDLogError(@"Error: Could not move basilisk named %@", folderName);
                if(![fileManager removeItemAtPath:originalFolder error:nil]){
                    DDLogError(@"Error: Could not delete either!");
                }
            }
            
        }

    }

    [fileManager removeItemAtPath:emulatorsTempDirectory error:nil];
    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@.zip", emulatorsTempDirectory] error:nil];
    
    [shallowDirectoryList release];

    [self scanEmulators];

}

- (BOOL)assembleBasiliskInDirectory:(NSString *)directory withName:(NSString *)folderName {

    DDLogVerbose(@"Assembling");
    
    int errors = 0;
    
    NSString * finalDirectory     = [[NSString alloc] initWithFormat:@"%@/%@", directory, folderName];
    NSString * appDirectory       = [[NSString alloc] initWithFormat:@"%@/Basilisk II.app", finalDirectory];
    NSString * contentsDirectory  = [[NSString alloc] initWithFormat:@"%@/Contents", appDirectory];
    NSString * macOSDirectory     = [[NSString alloc] initWithFormat:@"%@/MacOS", contentsDirectory];
    NSString * resourcesDirectory = [[NSString alloc] initWithFormat:@"%@/Resources", contentsDirectory];

    NSString * plistFilePathFrom  = [[NSString alloc] initWithFormat:@"%@/Info.plist", finalDirectory];
    NSString * unixFilePathFrom   = [[NSString alloc] initWithFormat:@"%@/BasiliskII", finalDirectory];
    NSString * iconFilePathFrom   = [[NSString alloc] initWithFormat:@"%@/BasiliskII.icns", directory];

    NSString * plistFilePathTo    = [[NSString alloc] initWithFormat:@"%@/Info.plist", contentsDirectory];
    NSString * unixFilePathTo     = [[NSString alloc] initWithFormat:@"%@/BasiliskII", macOSDirectory];
    NSString * iconFilePathTo     = [[NSString alloc] initWithFormat:@"%@/BasiliskII.icns", resourcesDirectory];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    // 1. Create Basilisk II.app
    
    if(![fileManager createDirectoryAtPath:appDirectory withIntermediateDirectories:YES attributes:nil error:NULL]) {
        DDLogError(@"Error: Could not create folder %@", appDirectory);
        errors++;
    }

    // 2. Create Basilisk II.app/Contents

    if(![fileManager createDirectoryAtPath:contentsDirectory withIntermediateDirectories:YES attributes:nil error:NULL]) {
        DDLogError(@"Error: Could not create folder %@", contentsDirectory);
        errors++;
    }

    // 3. Create Basilisk II.app/Contents/MacOS

    if(![fileManager createDirectoryAtPath:macOSDirectory withIntermediateDirectories:YES attributes:nil error:NULL]) {
        DDLogError(@"Error: Could not create folder %@", macOSDirectory);
        errors++;
    }

    // 4. Create Basilisk II.app/Contents/Resources

    if(![fileManager createDirectoryAtPath:resourcesDirectory withIntermediateDirectories:YES attributes:nil error:NULL]) {
        DDLogError(@"Error: Could not create folder %@", resourcesDirectory);
        errors++;
    }

    // 5. Move Info.plist into Basilisk II.app/Contents/
    
    if(![fileManager moveItemAtPath:plistFilePathFrom toPath:plistFilePathTo error:NULL]) {
        DDLogError(@"Error: Could not move plist to %@", plistFilePathTo);
        errors++;
    }
    
    // 6. Move BasiliskII into Basilisk II.app/Contents/MacOS/
    
    if(![fileManager moveItemAtPath:unixFilePathFrom toPath:unixFilePathTo error:NULL]) {
        DDLogError(@"Error: Could not move unix file to %@", unixFilePathTo);
        errors++;
    }
    
    // 7. Copy ../BasiliskII.icns to Basilisk II.app/Contents/Resources/
    
    if(![fileManager copyItemAtPath:iconFilePathFrom toPath:iconFilePathTo error:NULL]) {
        DDLogError(@"Error: Could not copy icon to %@", iconFilePathTo);
        errors++;
    }
    
    [iconFilePathTo release];
    [unixFilePathTo release];
    [plistFilePathTo release];
    [iconFilePathFrom release];
    [unixFilePathFrom release];
    [plistFilePathFrom release];
    [resourcesDirectory release];
    [macOSDirectory release];
    [contentsDirectory release];
    [appDirectory release];
    [finalDirectory release];
    
    if (errors > 0) return NO;
    else return YES;
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
