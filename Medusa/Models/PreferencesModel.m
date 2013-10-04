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

#import "PreferencesModel.h"
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h"
#import "DiskFilesEntityModel.h"
#import "VirtualMachinesEntityModel.h"
#import "RomFilesEntityModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_WARN;
//------------------------------------------------------------------------------

@implementation PreferencesModel

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

- (void)insertNewVirtualMachineWithData:(NSDictionary*)newData{
    //Do something
}

- (void)insertNewData:(NSDictionary*)newData inVirtualMachine:(NSManagedObject*)virtualMachine{
    //Do something
}

- (void)savePreferencesFile:(NSArray *)dataToSave ForFile:(NSString*)filePath {
    DDLogVerbose(@"Save data: %@", dataToSave);
    
    //NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@", NSHomeDirectory(), @".basilisk_ii_prefs"];
    
    NSMutableString * newContent = [[NSMutableString alloc] init];
    
    for (NSDictionary * dataElement in dataToSave) {
        for(id key in dataElement){
            DDLogVerbose(@"key=%@ value=%@", key, [dataElement objectForKey:key]);
            [newContent appendString:[NSString stringWithFormat:@"%@ %@", key, [dataElement objectForKey:key]]];
            [newContent appendString:@"\n"];
        }
    }
    DDLogVerbose(@"%@", filePath);
    [newContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [newContent release];
    
}

- (NSMutableArray*)getVirtualMachineData:(VirtualMachinesEntityModel *)virtualMachine {
    
    //The idea here is to return an array with dictionaries inside.
    //The returning object is the array that follows.
    
    NSMutableArray * allData = [[NSMutableArray alloc] initWithCapacity:1]; //Return object.

    //First we need the managed object context.
    [self setManagedObjectContext:[virtualMachine managedObjectContext]];
    
    //Now the requests.
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSError * error = nil;
    
    //--------------------------------------------------------------------------
    //1. The Macintosh Model
    
    int modelId = [[virtualMachine macModel] intValue];
    
    NSDictionary * macModelSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%ld", modelId], @"modelid",
            nil
    ];
    
    [allData addObject:macModelSettings];
    [macModelSettings release];

    //--------------------------------------------------------------------------
    //2. The processor
    
    // JIT defaults to "true" in some distributions.
    // Need to force to false to have it working properly!
    
    //    processorType
    //    cpu 1/2/3/0 check!
    
    int processorId = [[virtualMachine processorType] intValue];
    
    NSDictionary * macProcessorType = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%ld", processorId]
            , @"cpu"
            , nil
    ];
    
    [allData addObject:macProcessorType];
    [macProcessorType release];
    
    
    //    jitEnabled
    //    jit <true/false>
    
    if ( [[virtualMachine jitEnabled] boolValue] && processorId == 3) {
        
        NSDictionary * macJitEnabled = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                  @"true"
                , @"jit"
                , nil
        ];
        
        [allData addObject:macJitEnabled];
        [macJitEnabled release];
        
        
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
        
        int chacheKbSize = [[virtualMachine processorType] intValue];
        
        if (chacheKbSize != 8192 && chacheKbSize > 2048) {
            
            NSDictionary * macJitCache = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [NSString stringWithFormat:@"%ld", chacheKbSize]
                , @"jitcachesize"
                , nil
            ];
            
            [allData addObject:macJitCache];
            [macJitCache release];
            
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

    while (object = [rowEnumerator nextObject]) {
        DiskFilesEntityModel * unbootableDriveObject = [object drive];
        DDLogCInfo(@"DAMN --- %@", [unbootableDriveObject fileName]);
        NSDictionary * unbootableDrive = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [unbootableDriveObject filePath], @"disk",
                nil
        ];
        [allData addObject:unbootableDrive];
        [unbootableDrive release];
    }

    [sortPosition release]; 

    //--------------------------------------------------------------------------
    //5. Networking
    
    // Here we must enforce the negative for recent versions of B2.
    // An empty value will do.
    
    if ( [[virtualMachine network] boolValue] == YES) {
        NSDictionary * networkSettings = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                @"slirp", @"ether",
                nil
        ];
        
        [allData addObject:networkSettings];
        [networkSettings release];
    }
    
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
                    [[virtualMachine networkUDPPort] stringValue], @"udpport",
                    nil
            ];
            
            [allData addObject:udpPortSettings];
            [udpPortSettings release];
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
            [shareSettings setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"StandardSharePath"] forKey:@"extfs"];
        } else  if ([virtualMachine sharedFolder] != nil ) {
            [shareSettings setValue:[virtualMachine sharedFolder] forKey:@"extfs"];
        }
    }
    
    [allData addObject:shareSettings];
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
    
    //--------------------------------------------------------------------------
    //7. Serial data
    
    //--------------------------------------------------------------------------
    //8. ROM information
    
    NSDictionary * romSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat: [[virtualMachine romFile] filePath]], @"rom",
            nil
    ];
    
    [allData addObject:romSettings];
    [romSettings release];
    
    //--------------------------------------------------------------------------
    //9. Memory information
    //Default is 8 MB
    
    int totalMemory = [[virtualMachine memory] intValue]*1024*1024;
    
    NSDictionary * memorySettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", totalMemory], @"ramsize",
            nil
    ];
    
    [allData addObject:memorySettings];
    [memorySettings release];
    
    //--------------------------------------------------------------------------
    //10. Advanced information
    
//    NSDictionary * screenSettings = [[NSDictionary alloc]
//        initWithObjectsAndKeys:
//            [NSString stringWithFormat:@"win/%d/%d/%d", 512, 384, 16], @"screen",
//            nil
//    ];
//    
//    [allData addObject:screenSettings];

    [request release];
    //End of requests.
    
    
    
    return [allData autorelease];
    
    
    //DDLogVerbose(@"%@", [[virtualMachine objectID] URIRepresentation]);

    
}

- (void)savePreferencesFile:(NSString *)preferencesFilePath ForVirtualMachine:(VirtualMachinesEntityModel *)virtualMachine {
    //[NSApp delegate]
    NSArray  * currentVmData = [self getVirtualMachineData: virtualMachine];
    [self savePreferencesFile:currentVmData ForFile: preferencesFilePath];
}

@end
