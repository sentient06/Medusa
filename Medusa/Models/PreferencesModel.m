//
//  CoreDataModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 04/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "PreferencesModel.h"
#import "RelationshipVirtualMachinesDrivesModel.h"
#import "DrivesModel.h"
#import "VirtualMachinesModel.h"
#import "RomFilesModel.h"


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
    NSLog(@"Save data: %@", dataToSave);
    
    //NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@", NSHomeDirectory(), @".basilisk_ii_prefs"];
    
    NSMutableString * newContent = [[NSMutableString alloc] init];
    
    for (NSDictionary * pedaco in dataToSave) {
        for(id key in pedaco){
            NSLog(@"key=%@ value=%@", key, [pedaco objectForKey:key]);
            [newContent appendString:[NSString stringWithFormat:@"%@ %@", key, [pedaco objectForKey:key]]];
            [newContent appendString:@"\n"];
        }
    }
    NSLog(@"%@", filePath);
    [newContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [newContent release];
    
}

- (NSMutableArray*)getVirtualMachineData:(VirtualMachinesModel*)virtualMachine {
    
    //The idea here is to return an array with dictionaries inside.
    //The returning object is the array that follows.
    
    NSMutableArray *allData = [[NSMutableArray alloc] initWithCapacity:1]; //Return object.

    //First we need the managed object context.
    [self setManagedObjectContext:[virtualMachine managedObjectContext]];
    
    //Now the requests.
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    //--------------------------------------------------------------------------
    //1. The bootable drives
    
    NSEntityDescription *vmDrivesRelationship = [
        NSEntityDescription
                 entityForName:@"RelationshipVirtualMachinesDrives"
        inManagedObjectContext:managedObjectContext
    ];
    
    //Need to set the vm object in relationship table:
    NSPredicate *predicate = [
        NSPredicate
        predicateWithFormat: @"virtualMachine = %@ AND bootable = 1",
        virtualMachine
    ];
    
    
    [request setEntity:    vmDrivesRelationship];
    [request setPredicate: predicate];
    NSArray *bootableDriveResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"%@", bootableDriveResult);
    
    for (RelationshipVirtualMachinesDrivesModel * object in bootableDriveResult) {
        DrivesModel * bootableDriveObject = [object drive];
        NSDictionary * bootableDrive = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [bootableDriveObject filePath], @"disk",
                nil
        ];
        
        [allData addObject:bootableDrive];
        [bootableDrive release];
    }
    
    //--------------------------------------------------------------------------
    //2. The unbootable drives
    
    //vmDrivesRelationship set in step 1.
    
    //Need to set the vm object in relationship table:
    predicate = [
        NSPredicate
        predicateWithFormat: @"virtualMachine = %@ AND bootable = 0",
        virtualMachine
    ];
    
    //[request setEntity:    vmDrivesRelationship];
    [request setPredicate: predicate];
    NSArray *unbootableDriveResult = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (RelationshipVirtualMachinesDrivesModel * object in unbootableDriveResult) {
        DrivesModel * unbootableDriveObject = [object drive];
        NSDictionary * unbootableDrive = [[NSDictionary alloc]
            initWithObjectsAndKeys:
                [unbootableDriveObject filePath], @"disk",
                nil
        ];
        
        [allData addObject:unbootableDrive];
        [unbootableDrive release];
    }

    //--------------------------------------------------------------------------
    //3. Shares
    
    //--------------------------------------------------------------------------
    //4. SCSI data
    
    //--------------------------------------------------------------------------
    //5. Display data
    
    NSDictionary * screenSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat:@"win/%@/%@/%d",
             [virtualMachine displayWidth],
             [virtualMachine displayHeight], 32
            ], @"screen",
            nil
    ];
    
    [allData addObject:screenSettings];
    [screenSettings release];
    
    //--------------------------------------------------------------------------
    //6. Serial data
    
    //--------------------------------------------------------------------------
    //7. Model information (ROM)
    
    NSDictionary * romSettings = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat: [[virtualMachine model] filePath]], @"rom",
            nil
    ];
    
    [allData addObject:romSettings];
    [romSettings release];
    
    //--------------------------------------------------------------------------
    //8. Memory information
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
    //9. Advanced information
    
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
    
    
    //NSLog(@"%@", [[virtualMachine objectID] URIRepresentation]);
    
    /*
     drives [Drives]
     
     {"disk", TYPE_STRING, true,         "device/file name of Mac volume"},
     {"floppy", TYPE_STRING, true,       "device/file name of Mac floppy drive"},
     {"cdrom", TYPE_STRING, true,        "device/file names of Mac CD-ROM drive"},
     
     shares [Shares]
     {"extfs", TYPE_STRING, false,       "root path of ExtFS"},
     
     ! static
     {"scsi0", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 0"},
     {"scsi1", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 1"},
     {"scsi2", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 2"},
     {"scsi3", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 3"},
     {"scsi4", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 4"},
     {"scsi5", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 5"},
     {"scsi6", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 6"},
     
     displayHeight
     displayWidth
     fullScreen
     {"screen", TYPE_STRING, false,      "video mode"},
     {"windowmodes", TYPE_INT32, false,  "bitmap of allowed window video modes"},
     {"screenmodes", TYPE_INT32, false,  "bitmap of allowed fullscreen video modes"},
     
     ! static
     {"seriala", TYPE_STRING, false,     "device name of Mac serial port A"},
     {"serialb", TYPE_STRING, false,     "device name of Mac serial port B"},
     
     model [RomFiles]
     {"rom", TYPE_STRING, false,         "path of ROM file"},
     
     bootDrive ?
     {"bootdrive", TYPE_INT32, false,    "boot drive number"},
     
     ! static
     {"bootdriver", TYPE_INT32, false,   "boot driver number"},
     
     memory
     {"ramsize", TYPE_INT32, false,      "size of Mac RAM in bytes"},
     
     ! static
     {"frameskip", TYPE_INT32, false,    "number of frames to skip in refreshed video modes"},
     {"gfxaccel", TYPE_BOOLEAN, false,   "turn on QuickDraw acceleration"},
     {"nocdrom", TYPE_BOOLEAN, false,    "don't install CD-ROM driver"},
     {"nonet", TYPE_BOOLEAN, false,      "don't use Ethernet"},
     {"nosound", TYPE_BOOLEAN, false,    "don't enable sound output"},
     {"nogui", TYPE_BOOLEAN, false,      "disable GUI"},
     {"noclipconversion", TYPE_BOOLEAN, false, "don't convert clipboard contents"},
     {"ignoresegv", TYPE_BOOLEAN, false, "ignore illegal memory accesses"},
     {"ignoreillegal", TYPE_BOOLEAN, false, "ignore illegal instructions"},
     
     jitEnabled
     {"jit", TYPE_BOOLEAN, false,        "enable JIT compiler"},
     
     ! static
     {"jit68k", TYPE_BOOLEAN, false,     "enable 68k DR emulator"},
     {"keyboardtype", TYPE_INT32, false, "hardware keyboard type"},
     */
    
    
    
    
    
    
    
}

@end
