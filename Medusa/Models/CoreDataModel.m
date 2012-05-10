//
//  CoreDataModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 04/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "CoreDataModel.h"

@implementation CoreDataModel

- (void) insertNewVirtualMachineWithData:(NSDictionary*)newData{
    //Do something
}

- (void) insertNewData:(NSDictionary*)newData inVirtualMachine:(NSManagedObject*)virtualMachine{
    //Do something
}

- (NSMutableArray*) virtualMachineData:(NSManagedObject*)virtualMachine{
    
    NSMutableArray *allData = [[NSMutableArray alloc] initWithCapacity:1];
    NSString *name = [virtualMachine valueForKey:@"name"];
    NSLog(@"%@", name);
    [allData addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        name, @"name"
                        , nil]];
    
    
    
    /*
     {"disk", TYPE_STRING, true,         "device/file name of Mac volume"},
     {"floppy", TYPE_STRING, true,       "device/file name of Mac floppy drive"},
     {"cdrom", TYPE_STRING, true,        "device/file names of Mac CD-ROM drive"},
     {"extfs", TYPE_STRING, false,       "root path of ExtFS"},
     {"scsi0", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 0"},
     {"scsi1", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 1"},
     {"scsi2", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 2"},
     {"scsi3", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 3"},
     {"scsi4", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 4"},
     {"scsi5", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 5"},
     {"scsi6", TYPE_STRING, false,       "SCSI target for Mac SCSI ID 6"},
     {"screen", TYPE_STRING, false,      "video mode"},
     {"windowmodes", TYPE_INT32, false,  "bitmap of allowed window video modes"},
     {"screenmodes", TYPE_INT32, false,  "bitmap of allowed fullscreen video modes"},
     {"seriala", TYPE_STRING, false,     "device name of Mac serial port A"},
     {"serialb", TYPE_STRING, false,     "device name of Mac serial port B"},
     {"rom", TYPE_STRING, false,         "path of ROM file"},
     {"bootdrive", TYPE_INT32, false,    "boot drive number"},
     {"bootdriver", TYPE_INT32, false,   "boot driver number"},
     {"ramsize", TYPE_INT32, false,      "size of Mac RAM in bytes"},
     {"frameskip", TYPE_INT32, false,    "number of frames to skip in refreshed video modes"},
     {"gfxaccel", TYPE_BOOLEAN, false,   "turn on QuickDraw acceleration"},
     {"nocdrom", TYPE_BOOLEAN, false,    "don't install CD-ROM driver"},
     {"nonet", TYPE_BOOLEAN, false,      "don't use Ethernet"},
     {"nosound", TYPE_BOOLEAN, false,    "don't enable sound output"},
     {"nogui", TYPE_BOOLEAN, false,      "disable GUI"},
     {"noclipconversion", TYPE_BOOLEAN, false, "don't convert clipboard contents"},
     {"ignoresegv", TYPE_BOOLEAN, false, "ignore illegal memory accesses"},
     {"ignoreillegal", TYPE_BOOLEAN, false, "ignore illegal instructions"},
     {"jit", TYPE_BOOLEAN, false,        "enable JIT compiler"},
     {"jit68k", TYPE_BOOLEAN, false,     "enable 68k DR emulator"},
     {"keyboardtype", TYPE_INT32, false, "hardware keyboard type"},
     */
    
    
    
    
    
    
    return allData;
}

@end
