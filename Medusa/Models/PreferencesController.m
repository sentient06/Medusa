//
//  PreferencesModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 04/05/2012.
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

#import "PreferencesController.h"
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h"
#import "DiskFilesEntityModel.h"
#import "VirtualMachinesEntityModel.h"
#import "RomFilesEntityModel.h"
#import "EmulatorsEntityModel.h"
#import "AppDelegate.h"
#import "RomController.h"
#import "DiskController.h"
#import "EmulatorModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation PreferencesController

//------------------------------------------------------------------------------
// Manual getters

#pragma mark – Manual getters

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

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Writting actions

#pragma mark – Writting actions

/*!
 * @method      savePreferences:InPath:ForVirtualMachine:
 * @abstract    Saves text file with preferences.
 * @discussion  SheepShaver emulates a G4 processor, 100MHz and reports Gestalt
 *              67 - Power Mac 9500
 */
- (void)savePreferences:(NSArray *)dataToSave
                 InPath:(NSString*)filePath
      ForVirtualMachine:(VirtualMachinesEntityModel *)virtualMachine {

    DDLogVerbose(@"Save data: %@", dataToSave);

    int emulatorFamily = [[[virtualMachine emulator] family] intValue];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    if ([fileManager fileExistsAtPath:filePath])
        [fileManager removeItemAtPath:filePath error:&error];
    
    //NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@", NSHomeDirectory(), @".basilisk_ii_prefs"];
    
    NSMutableString * newContent = [[NSMutableString alloc] initWithString:@""];
    
    for (NSDictionary * dataElement in dataToSave) {
        for(id key in dataElement){
            DDLogVerbose(@"key=%@ value=%@", key, [dataElement objectForKey:key]);
            [newContent appendString:[NSString stringWithFormat:@"%@ %@", key, [dataElement objectForKey:key]]];
            [newContent appendString:@"\n"];
        }
    }

    NSMutableString * emulatorDefaults = [[NSMutableString alloc] initWithString:@""];
    NSMutableString * universalDefaults = [[NSMutableString alloc] initWithString:
        [[NSUserDefaults standardUserDefaults] stringForKey:@"extraUniversalPreferences"] ?: @""
    ];

    if (emulatorFamily == basiliskFamily) {
        [emulatorDefaults appendString:
            [[NSUserDefaults standardUserDefaults] stringForKey:@"extraBasiliskPreferences"] ?: @""
        ];
    }
    
    if (emulatorFamily == sheepshaverFamily) {
        [emulatorDefaults appendString:
            [[NSUserDefaults standardUserDefaults] stringForKey:@"extraSheepshaverPreferences"] ?: @""
        ];
    }
    
    if ([universalDefaults length] > 0) {
        [newContent appendString:universalDefaults];
        [newContent appendString:@"\n"];
    }
    
    if ([emulatorDefaults length] > 0) {
        [newContent appendString:emulatorDefaults];
        [newContent appendString:@"\n"];
    }
    
    if ([virtualMachine extraPreferences]) {
        [newContent appendString:[virtualMachine extraPreferences]];
        [newContent appendString:@"\n"];
    }
    
    DDLogVerbose(@">>> New content: %@", newContent);
    
    DDLogVerbose(@"%@", filePath);
    [newContent writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [emulatorDefaults release];
    [universalDefaults release];
    [newContent release];
}

/*!
 * @method      getVirtualMachineData:
 * @abstract    Returns an array with key-value pairs of settings from the coredata.
 */
- (NSMutableArray*)getVirtualMachineData:(VirtualMachinesEntityModel *)virtualMachine
                       forEmulatorFamily:(int)emulatorFamily {
    
    //The idea here is to return an array with dictionaries inside.
    //The returning object is the array that follows.
    
    NSFileManager  * fileManager = [NSFileManager defaultManager];    
    NSMutableArray * allData = [[NSMutableArray alloc] initWithCapacity:1]; //Return object.

    //First we need the managed object context.
    [self setManagedObjectContext:[virtualMachine managedObjectContext]];
    
    //Now the requests.
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSError * error = nil;
    
    //--------------------------------------------------------------------------
    //1. The Macintosh Model
    
    if (emulatorFamily == basiliskFamily) {
        int modelId = [[virtualMachine macModel] intValue] - 6;
        
        NSDictionary * macModelSettings = [
            [NSDictionary alloc]
            initWithObjectsAndKeys: [NSString stringWithFormat:@"%d", modelId]
            , @"modelid"
            , nil
        ];
        
        [allData addObject:macModelSettings];
        [macModelSettings release];
    }

    //--------------------------------------------------------------------------
    //2. The processor
    
    // JIT defaults to "true" in some distributions.
    // Need to force to false to have it working properly!
    
    //    processorType
    //    cpu 1/2/3/0 check!
    int processorId = [[virtualMachine processorType] intValue];

    if (emulatorFamily == basiliskFamily) {
        NSDictionary * macProcessorType = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [NSString stringWithFormat:@"%d", processorId]
                , @"cpu"
                , nil
        ];
        [allData addObject:macProcessorType];
        [macProcessorType release];
    }
    
    //    jitEnabled
    //    jit <true/false>
    
    if ( [[virtualMachine jitEnabled] boolValue] && (processorId == MC68040 || processorId == PPC7400)) {
        
        NSDictionary * macJitEnabled = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                  @"true"
                , @"jit"
                , nil
        ];
        
        [allData addObject:macJitEnabled];
        [macJitEnabled release];
        
        if (emulatorFamily == basiliskFamily) {
            //    lazyCacheEnabled
            //    jitlazyflush <"true" or "false">
            
            NSDictionary * macLazyCache = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                    [[virtualMachine lazyCacheEnabled] boolValue] ? @"true" : @"false"
                    , @"jitlazyflush"
                    , nil
            ];
            
            [allData addObject:macLazyCache];
            [macLazyCache release];
            
            //    fpuEnabled
            //    fpu
            NSDictionary * macFpu = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                    [[virtualMachine fpuEnabled] boolValue] ? @"true" : @"false"
                    , @"jitfpu"
                    , nil
            ];
            
            [allData addObject:macFpu];
            [macFpu release];
            
            
            //    jitCacheSize
            //    jitcachesize <size>
            
            int chacheKbSize = [[virtualMachine jitCacheSize] intValue];
            
            if (chacheKbSize != 8192 && chacheKbSize > 2048) {
                
                NSDictionary * macJitCache = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d", chacheKbSize]
                    , @"jitcachesize"
                    , nil
                ];
                
                [allData addObject:macJitCache];
                [macJitCache release];
                
            }
        }
        
    } else {
        NSDictionary * macJitEnabled = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                  @"false"
                , @"jit"
                , nil
        ];        
        [allData addObject:macJitEnabled];
        [macJitEnabled release]; 
    }
    
    if (emulatorFamily == sheepshaverFamily) {
        NSDictionary * compilation68k = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [[virtualMachine enable68k] boolValue] ? @"true" : @"false"
                , @"jit68k"
                , nil
        ];
        [allData addObject:compilation68k];
        [compilation68k release];
    }
    
    //--------------------------------------------------------------------------
    //3. The disks
    
    NSEntityDescription * vmDrivesRelationship = [
        NSEntityDescription
                 entityForName:@"RelationshipVirtualMachinesDiskFiles"
        inManagedObjectContext:managedObjectContext
    ];
    
    //Need to set the vm object in relationship table:
    NSPredicate * predicate = [
        NSPredicate
        predicateWithFormat: @"virtualMachine = %@",
        virtualMachine
    ];
    
    NSSortDescriptor * sortPosition = [[NSSortDescriptor alloc] initWithKey:@"positionIndex" ascending:YES];

    [request setEntity: vmDrivesRelationship];
    [request setPredicate: predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:sortPosition]];
    
    NSArray * drivesResult = [managedObjectContext executeFetchRequest:request error:&error];
    NSEnumerator * rowEnumerator = [drivesResult objectEnumerator];
    RelationshipVirtualMachinesDiskFilesEntityModel * object;
    
    BOOL bootFromCD = NO;

    while (object = [rowEnumerator nextObject]) {
        DiskFilesEntityModel * unbootableDriveObject = [object diskFile];
        DDLogVerbose(@"DAMN --- %@", [unbootableDriveObject fileName]);

        int diskType = [[unbootableDriveObject type] intValue];
        NSString * strType;
        if (diskType == typeDiskette) {
            strType = [[NSString alloc] initWithString:@"floppy"];
        } else
        if (diskType == typeCDROM) {
            strType = [[NSString alloc] initWithString:@"cdrom"];
            if ([[object positionIndex] intValue] == 0) {
                if ([unbootableDriveObject canBoot]) {
                    bootFromCD = YES;
                }
            }
        } else {
            strType = [[NSString alloc] initWithString:@"disk"];
        }
        NSDictionary * unbootableDrive = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [unbootableDriveObject filePath], strType,
                nil
        ];
        [allData addObject:unbootableDrive];
        [unbootableDrive release];
        [strType release];
    }

    [sortPosition release];
    
    if (bootFromCD) {
        NSDictionary * bootFromCDEntry = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                @"-62", @"bootdriver",
                nil
        ];
        [allData addObject:bootFromCDEntry];
        [bootFromCDEntry release];
    }

    
//    bootdriver <driver number>
//    
//    Specify MacOS driver number of boot volume. "0" (the default) means
//    "boot from first bootable volume". Use "-62" to boot from CD-ROM.

    //--------------------------------------------------------------------------
    //5. Networking
    
    // Here we must enforce the negative for recent versions of B2.
    // An empty value will do.
    
    if ( [[virtualMachine network] boolValue] == YES) {
        
        NSString * networkInterface;
        
        if ( [[virtualMachine networkTap0] boolValue] == YES && emulatorFamily == basiliskFamily) {
            networkInterface = @"etherhelper/tap0/bridge0/en0";
        } else {
            networkInterface = @"slirp";
        }

        NSDictionary * networkSettings = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                networkInterface, @"ether",
                nil
        ];
        
        [allData addObject:networkSettings];
        [networkSettings release];
//        [networkInterface release];
    }
    if (emulatorFamily == basiliskFamily) {
        if ( [[virtualMachine networkUDP] boolValue] == YES) {
            NSDictionary * udpSettings = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                    @"true", @"udptunnel",
                    nil
            ];
            
            [allData addObject:udpSettings];
            [udpSettings release];
            
            if ( [[virtualMachine networkUDPPort] intValue] != 6066) {
                NSDictionary * udpPortSettings = [[NSDictionary alloc]
                    initWithObjectsAndKeys:
                        [[virtualMachine networkUDPPort] stringValue]
                        , @"udpport"
                        , nil
                ];
                [allData addObject:udpPortSettings];
                [udpPortSettings release];
            }
            
        }
    }

    // ether <ethernet card description> slirp
    // udptunnel <"true" or "false"> (adv?)
    // udpport <IP port number> (df: 6066)

    NSMutableDictionary * shareSettings = [[NSMutableDictionary alloc]
        initWithObjectsAndKeys:
            @"", @"extfs",
            nil
    ];

    if ( [[virtualMachine shareEnabled] boolValue] == YES) {
        if ( [[virtualMachine useDefaultShare] boolValue] ) {
            [shareSettings setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"StandardSharePath"]
            stringByExpandingTildeInPath                         
            ]forKey:@"extfs"];
        } else  if ([virtualMachine sharedFolder] != nil ) {
            [shareSettings setValue:[virtualMachine sharedFolder] forKey:@"extfs"];
        }
        [allData addObject:shareSettings];
    }
    
    [shareSettings release];

    //--------------------------------------------------------------------------
    //5. SCSI data

    //--------------------------------------------------------------------------
    //6. Display data

    NSMutableString * fullScreen    = [[NSMutableString alloc] initWithString:@"win"];
    NSNumber * screenWidth   = [virtualMachine displayWidth];
    NSNumber * screenHeight  = [virtualMachine displayHeight];
    NSNumber * colourDepth   = [virtualMachine displayColourDepth];
    NSNumber * dynamicUpdate = [virtualMachine displayDynamicUpdate];
    NSNumber * frameSkip     = [virtualMachine displayFrameSkip];

    if ([[virtualMachine fullScreen] boolValue] == YES) {
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
        [fullScreen setString:@"dga"];
        screenWidth  = [NSNumber numberWithFloat: screenRect.size.width];
        screenHeight = [NSNumber numberWithFloat: screenRect.size.height];
    }

    NSDictionary * screenSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%@/%@/%@/%@",
             fullScreen,
             screenWidth,
             screenHeight, colourDepth
            ], @"screen",
            nil
    ];

    [allData addObject:screenSettings];
    [screenSettings release];
    [fullScreen release];

    if ([dynamicUpdate boolValue] == YES) {
        frameSkip = [NSNumber numberWithInt:0];
    } else {
        if ([frameSkip intValue] == 0)
        frameSkip = [NSNumber numberWithInt:-1]; //ignores
    }

    if ([frameSkip intValue] >= 0) {
        NSDictionary * frameSkipSettings = [[NSDictionary alloc]
            initWithObjectsAndKeys:
              [frameSkip stringValue]
                , @"frameskip"
                , nil
        ]; 

        [allData addObject:frameSkipSettings];
        [frameSkipSettings release];
    }

    if (emulatorFamily == sheepshaverFamily) {
        // gfxaccel <"true" or "false">
        NSDictionary * quickdraw = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [[virtualMachine quickdrawAcceleration] boolValue] ? @"true" : @"false"
                , @"gfxaccel"
                , nil
        ];
        [allData addObject:quickdraw];
        [quickdraw release];
    }
    
    //--------------------------------------------------------------------------
    //7. Serial data

    //--------------------------------------------------------------------------
    //8. ROM information
    
    DDLogVerbose(@"Rom file is %@", [virtualMachine romFile] == NULL ? @"null" : @"not-null");

    NSString * romPath;
    
    if ([virtualMachine romFile] == NULL) {
        romPath = @"";
    } else {
        romPath = [[virtualMachine romFile] filePath];
    }
        
    NSDictionary * romSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys: romPath, @"rom", nil
    ];

    [allData addObject:romSettings];
    [romSettings release];

    //--------------------------------------------------------------------------
    //9. Memory information
    //Default is 8 MB

    int totalMemory = [[virtualMachine memory] intValue] * 1024 * 1024;

    NSDictionary * memorySettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
          [NSString stringWithFormat:@"%d", totalMemory]
            , @"ramsize"
            , nil
    ];

    [allData addObject:memorySettings];
    [memorySettings release];

    //--------------------------------------------------------------------------
    //10. Advanced information
    //10. Keyboard

    if ([[virtualMachine rawKeycodes] boolValue]) {

        NSString * keycodesFile = [
             [NSString alloc] initWithFormat:@"%@/BasiliskII_keycodes",
            [[NSApp delegate] applicationSupportDirectory]
        ];
        
        BOOL existingKeycodesFile = [fileManager fileExistsAtPath:keycodesFile];
        
        if (!existingKeycodesFile) {
            NSString * originalKeycodeFile = [
                [NSString alloc] initWithString:[
                    [NSBundle mainBundle] pathForResource:@"BasiliskII_keycodes" ofType:nil
                ]
            ];
            DDLogVerbose(@"No keycodes file, copying %@", originalKeycodeFile);
            [fileManager copyItemAtPath:originalKeycodeFile toPath:keycodesFile error:&error];
            [originalKeycodeFile release];
        }
        NSDictionary * rawKeycodesSettings = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                @"true", @"keycodes",
                nil
        ];
        [allData addObject:rawKeycodesSettings];
        [rawKeycodesSettings release];
        
        NSDictionary * keycodesFileData = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                keycodesFile, @"keycodefile",
                nil
        ];
        [allData addObject:keycodesFileData];
        [keycodesFileData release];
        
        // true looks for file in /usr/local/share/BasiliskII/keycodes
        // or it uses keycodefile
        // the file won't be found in snow leopard
        
        [keycodesFile release];

    } else {
        if ([virtualMachine keyboardLayout]) {
            NSDictionary * keycodesSettings = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                  [virtualMachine keyboardLayout]
                    , @"keyboardtype"
                    , nil
            ];
            [allData addObject:keycodesSettings];
            [keycodesSettings release];
        }

    }
    
    //--------------------------------------------------------------------------
    // Others
    
    if (emulatorFamily == sheepshaverFamily) {
        // gfxaccel <"true" or "false">
        NSDictionary * idle = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [[virtualMachine idleWait] boolValue] ? @"true" : @"false"
                , @"idlewait"
                , nil
        ];
        [allData addObject:idle];
        [idle release];
        
        NSDictionary * noclip = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [[virtualMachine noClipboardConversion] boolValue] ? @"true" : @"false"
                , @"noclipconversion"
                , nil
        ];
        [allData addObject:noclip];
        [noclip release];        
    }

    [request release];

    //End of requests.

    return [allData autorelease];

}

/*!
 * @method      savePreferencesFile:ForVirtualMachine:
 * @abstract    Creates preferences file path and directories for a given VM.
 */
- (void)savePreferencesFile:(NSString *)preferencesFilePath
          ForVirtualMachine:(VirtualMachinesEntityModel *)virtualMachine {

    NSMutableString * filePath = [[[NSMutableString alloc] initWithString:preferencesFilePath] autorelease];
    int emulatorFamily = [[[virtualMachine emulator] family] intValue];
    
    if ([virtualMachine emulator] == nil) {
        DDLogInfo(@"Emulator is nil, aborting file creation.");
        return;
    }

    NSMutableArray * currentVmData;

    if (emulatorFamily == basiliskFamily || emulatorFamily == sheepshaverFamily) {
        currentVmData = [self getVirtualMachineData: virtualMachine forEmulatorFamily:emulatorFamily];
    } else {
        DDLogInfo(@"Emulator not supported, aborting file creation.");
        return;
    }
    
    if (emulatorFamily == sheepshaverFamily) {

        NSFileManager * fileManager = [NSFileManager defaultManager];

        NSString * sheepShaverPreferencesPath = [
            [NSString alloc] initWithFormat:
                @"%@.sheepvm",
                filePath
        ];

        BOOL isDir = NO;

        if(![fileManager fileExistsAtPath:sheepShaverPreferencesPath isDirectory:&isDir])
            if(![fileManager createDirectoryAtPath:sheepShaverPreferencesPath withIntermediateDirectories:YES attributes:nil error:NULL])
                DDLogError(@"Error: Create -.sheepvm dir failed.");
        
        // Releases current path to generate again:
        filePath = [NSMutableString stringWithFormat: @"%@/prefs", sheepShaverPreferencesPath];
        
        NSString * nvramFile = [[[NSString alloc] initWithFormat: @"%@/nvram", sheepShaverPreferencesPath] autorelease];

        [sheepShaverPreferencesPath release];
        
        NSError * error;
        if ([fileManager fileExistsAtPath:nvramFile])
            if ([fileManager removeItemAtPath:nvramFile error:&error])
                [@"" writeToFile:nvramFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [self savePreferences:currentVmData InPath:filePath ForVirtualMachine:virtualMachine];

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Reading actions

#pragma mark – Reading actions

/*!
 * @method      parsePreferencesFor:
 * @abstract    Reads text file and creates key-value pairs for insertion in coredata.
 */
+ (NSMutableArray *)parsePreferencesFor:(int)emulatorType {
    
    NSMutableArray * allData = [[NSMutableArray alloc] initWithCapacity:1]; //Return object.
    
    NSString * filePath;
    
    if (emulatorType == BasiliskII) {
        filePath = [@"~/.basilisk_ii_prefs" stringByExpandingTildeInPath];
    } else {
        filePath = [@"~/.sheepshaver_prefs" stringByExpandingTildeInPath];
    }
    
    // Reads everything from text:
    NSString * fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // Separates by new line:
    NSArray * allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString * line in allLinedStrings) {
        if (line.length) {
            NSRange spacePosition = [line rangeOfString:@" "];
            NSDictionary * valuePair = [[NSDictionary alloc]
                initWithObjectsAndKeys:
                      [line substringFromIndex:spacePosition.location+1]
                    , [line   substringToIndex:spacePosition.location]
                    , nil
            ];
            [allData addObject:valuePair];
        }
    }
    
    return [allData autorelease];
}

/*!
 * @method      insertData:intoVirtualMachine:
 * @abstract    Reads inserts parsed data into coredata's VM.
 */
- (void)insertData:(NSArray *)preferences intoVirtualMachine:(VirtualMachinesEntityModel *)virtualMachine {
    DDLogInfo(@"Parsing imported data");
    [virtualMachine retain];
    NSMutableArray * notParsed = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary * dataElement in preferences) {
        for(id key in dataElement){
            
            BOOL boolValueTrue  = [[dataElement objectForKey:key] isEqualToString:@"true" ] ||
                                  [[dataElement objectForKey:key] isEqualToString:@"yes"  ] ||
                                  [[dataElement objectForKey:key] isEqualToString:@"on"   ];
            BOOL boolValueFalse = [[dataElement objectForKey:key] isEqualToString:@"false"] ||
                                  [[dataElement objectForKey:key] isEqualToString:@"no"   ] ||
                                  [[dataElement objectForKey:key] isEqualToString:@"off"  ];
            
            BOOL valueIsBool = boolValueTrue || boolValueFalse;
            BOOL boolValue = boolValueTrue ? YES : NO;
 
            
            NSMutableString * newKey = [[NSMutableString alloc] initWithCapacity:20];
            //--------------------------------------------------------------------------
            // 1. The ROM
            if ([key isEqualToString: @"rom"]) {
                RomController * romObject = [[RomController alloc] autorelease];
                [romObject parseSingleRomFileAndSave:[dataElement objectForKey:key] inObjectContext:managedObjectContext];
                [virtualMachine setRomFile:[romObject currentRomObject]];
            } else
            //--------------------------------------------------------------------------
            // 2. The Macintosh Model
            if ([key isEqualToString: @"modelid"]) {
                [virtualMachine setMacModel:
                    [NSNumber numberWithInt:[[dataElement objectForKey:key] intValue]+6]
                ];
            } else
            //--------------------------------------------------------------------------
            // 3. The processor

            // Basilisk:
            if ([key isEqualToString: @"cpu"]) {
                int processor = [[dataElement objectForKey:key] intValue];
                [virtualMachine setProcessorType:[NSNumber numberWithInt:processor]];
            } else

            if ([key isEqualToString: @"jit"]) {
                if (valueIsBool)
                    [virtualMachine setJitEnabled:[NSNumber numberWithBool:boolValue]];
            } else
            
            if ([key isEqualToString: @"jitlazyflush"]) {
                if (valueIsBool)
                    [virtualMachine setLazyCacheEnabled:[NSNumber numberWithBool:boolValue]];
            } else
            
            if ([key isEqualToString: @"jitcachesize"]) {
                int size = [[dataElement objectForKey:key] intValue];
                [virtualMachine setJitCacheSize:[NSNumber numberWithInt:size]];
            } else
            if ([key isEqualToString: @"jitfpu"]) {
                int size = [[dataElement objectForKey:key] intValue];
                [virtualMachine setFpuEnabled:[NSNumber numberWithInt:size]];
            } else

            // SheepShaver:
            if ([key isEqualToString: @"jit68k"]) {
                if (valueIsBool)
                    [virtualMachine setEnable68k:[NSNumber numberWithBool:boolValue]];
            } else
            //--------------------------------------------------------------------------
            // 4. The disks
            
            if ([key isEqualToString: @"disk"]) {
                DiskController * diskObject = [[DiskController alloc] autorelease];
                [diskObject parseSingleDriveFileAndSave:[dataElement objectForKey:key] inObjectContext:managedObjectContext];
                RelationshipVirtualMachinesDiskFilesEntityModel * newRelationship = [
                NSEntityDescription
                    insertNewObjectForEntityForName:@"RelationshipVirtualMachinesDiskFiles"
                    inManagedObjectContext:managedObjectContext
                ];
                [newRelationship setDiskFile:[diskObject currentDriveObject]];
                [newRelationship setPositionIndex:[virtualMachine nextDiskIndex]];
                [virtualMachine addDisksObject:newRelationship];
            } else
            
            //--------------------------------------------------------------------------
            // 5. Networking
            
            if ([key isEqualToString:@"ether"]) {
                [virtualMachine setNetwork:[NSNumber numberWithBool:YES]];
                // Basilisk:
                if ([[dataElement objectForKey:key] isEqualToString:@"etherhelper/tap0/bridge0/en0"]) {
                    [virtualMachine setNetworkTap0:[NSNumber numberWithBool:YES]];
                }
            } else

            // Basilisk:
            if ([key isEqualToString:@"udptunnel"]) {
                if (valueIsBool)
                    [virtualMachine setNetworkUDP:[NSNumber numberWithBool:boolValue]];
            } else
            if ([key isEqualToString:@"udpport"]) {
                [virtualMachine setNetworkUDPPort:[NSNumber numberWithInt:[[dataElement objectForKey:key] intValue]]];
            } else
            
            // Share settings:
            if ([key isEqualToString:@"extfs"]) {
                [virtualMachine setShareEnabled:[NSNumber numberWithBool:YES]];
                NSString * defaultSharePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"StandardSharePath"];
                if ([[dataElement valueForKey:key] isEqualToString:defaultSharePath]) {
                    [virtualMachine setUseDefaultShare:[NSNumber numberWithBool:YES]];
                } else {
                    [virtualMachine setSharedFolder:[dataElement valueForKey:key]];
                }
            } else
            //--------------------------------------------------------------------------
            // 6. Display
            if ([key isEqualToString:@"screen"]) {
                
                // e.g dga/1024/768/2
                NSMutableString * screen = [[[NSMutableString alloc] initWithString:[dataElement valueForKey:key]] autorelease];
                NSMutableString * values; // = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
                NSRange strokePosition;

                // Fullscreen (dga/win) - - - - - - - - - - - - - - - - - - - - - - - -
                // First stroke, e.g dga + /1024/768/2
                strokePosition = [screen rangeOfString:@"/"];
                values = [NSMutableString stringWithString:[screen substringToIndex:strokePosition.location]];
                if ([values isEqualToString:@"dga"]) {
                    [virtualMachine setFullScreen:[NSNumber numberWithBool:YES]];
                } else {
                    [virtualMachine setFullScreen:[NSNumber numberWithBool:NO]];
                }
                
                // Width  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                // Get past the stroke, e.g 1024/768/2
                screen = [NSMutableString stringWithString:[screen substringFromIndex:strokePosition.location+1]];
                // Second stroke, e.g 1024 + /768/2
                strokePosition = [screen rangeOfString:@"/"];
                values = [NSMutableString stringWithString:[screen substringToIndex:strokePosition.location]];
                [virtualMachine setDisplayWidth:[NSNumber numberWithInt:[values intValue]]];
                
                // Height - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                // Get past the stroke, e.g 768/2
                screen = [NSMutableString stringWithString:[screen substringFromIndex:strokePosition.location+1]];
                // Second stroke, e.g 768 + /2
                strokePosition = [screen rangeOfString:@"/"];
                values = [NSMutableString stringWithString:[screen substringToIndex:strokePosition.location]];
                [virtualMachine setDisplayHeight:[NSNumber numberWithInt:[values intValue]]];

                // Colour depth - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                // Get past the stroke, e.g 2
                screen = [NSMutableString stringWithString:[screen substringFromIndex:strokePosition.location+1]];
                [virtualMachine setDisplayColourDepth:[NSNumber numberWithInt:[screen intValue]]];
               
            } else
            
            // Frame skip:
            if ([key isEqualToString:@"frameskip"]) {
                if ([[dataElement objectForKey:key] intValue] == 0) {
                    [virtualMachine setDisplayDynamicUpdate:[NSNumber numberWithBool:YES]];
                } else {
                    [virtualMachine setDisplayDynamicUpdate:[NSNumber numberWithBool:NO]];
                }
                [virtualMachine setDisplayFrameSkip:[NSNumber numberWithInt:[[dataElement objectForKey:key] intValue]]];
            } else
            
            // SheepShaver:
            if ([key isEqualToString:@"gfxaccel"]) {
                if (valueIsBool)
                    [virtualMachine setQuickdrawAcceleration:[NSNumber numberWithBool:boolValue]];
            } else
            //--------------------------------------------------------------------------
            // 7. Memory
            if ([key isEqualToString:@"ramsize"]) {
                int memory = [[dataElement objectForKey:key] intValue] / 1024 / 1024;
                [virtualMachine setMemory:[NSNumber numberWithInt:memory]];
            } else
            //--------------------------------------------------------------------------
            // 8. Keyboard
            if ([key isEqualToString:@"keycodes"]) {
                if (valueIsBool)
                    [virtualMachine setRawKeycodes:[NSNumber numberWithBool:boolValue]];
            } else
            if ([key isEqualToString:@"keycodefile"]) {
                [virtualMachine setRawKeycodes:[NSNumber numberWithBool:NO]];
            } else
            if ([key isEqualToString:@"keyboardtype"]) {
                [virtualMachine setKeyboardLayout:[NSNumber numberWithInt:[[dataElement objectForKey:key] intValue]]];
            } else
            //--------------------------------------------------------------------------
            // 9. SheepShaver specifics
            if ([key isEqualToString:@"idlewait"]) {
                if (valueIsBool)
                    [virtualMachine setIdleWait:[NSNumber numberWithBool:boolValue]];
            } else
            if ([key isEqualToString:@"noclipconversion"]) {
                if (valueIsBool)
                    [virtualMachine setNoClipboardConversion:[NSNumber numberWithBool:boolValue]];
            } else
            //--------------------------------------------------------------------------
            {
                [notParsed addObject:key];
            }
            //--------------------------------------------------------------------------
            [newKey release];
        }
    }

    // Fetches all emulators for this rom:
    NSArray * emulators = [
        EmulatorModel fetchAllAvailableEmulatorsForEmulatorType:[
            [[virtualMachine romFile] emulatorType] intValue
        ]
    ];
    if ([emulators count] > 0) {
        [virtualMachine setEmulator:[emulators objectAtIndex:0]];
    }

    DDLogInfo(@"These keys were not parsed: %@", notParsed);
    [notParsed release];
    [[NSApp delegate] saveCoreData];
    [virtualMachine release];
}
@end
