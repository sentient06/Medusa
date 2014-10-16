//
//  EmulatorModel.m
//  Medusa
//
//  Created by Gian2 on 30/09/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import "EmulatorModel.h"
#import "EmulatorsEntityModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
//#import "DDLog.h"
//#import "DDASLLogger.h"
//#import "DDTTYLogger.h"
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation EmulatorModel

+ (int)familyFromEmulatorType:(int)type {
    switch (type) {
        case EmulatorUnsupported:
            return noFamily;
            break;
        case vMacStandard:
        case vMacModelCompilation:
        case vMacOther1:
        case vMacOther2:
            return miniVMacFamily;
            break;
        case BasiliskII:
        case BasiliskIIOther1:
        case BasiliskIIOther2:
            return basiliskFamily;
            break;
        case vMacStandardAndBasiliskII:
        case vMacModelCompilationAndBasiliskII:
            return m68kFamily;
            break;
        case Sheepshaver:
        case SheepshaverOther1:
        case SheepshaverOther2:
            return sheepshaverFamily;
            break;
   }
    return undefinedFamily;
}

+ (NSArray *)fetchAllAvailableEmulatorsForEmulatorType:(int)emulatorType {

    int emulatorFamily = [EmulatorModel familyFromEmulatorType:emulatorType];
    //----------------------------------------------------------------------
    // Core-data part:

    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    NSError  * error;
//    NSString * escapedPath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSData   * fileAlias   = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];

    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [
        NSEntityDescription entityForName:@"Emulators"
            inManagedObjectContext:managedObjectContext
    ];
    NSPredicate         * predicate = [ NSPredicate
        predicateWithFormat: @"family = %d", emulatorFamily
    ];

    [request setEntity:entity];
    [request setPredicate: predicate];
//    NSInteger resultCount = [managedObjectContext countForFetchRequest:request error:&error];

//    if (resultCount > 0) {
//        DDLogVerbose(@"Got emulators");
    NSArray * drivesResult = [managedObjectContext executeFetchRequest:request error:&error];
//        NSEnumerator * rowEnumerator = [drivesResult objectEnumerator];
//        id * object;
//
//        while (object = [rowEnumerator nextObject]) {
//
//        }

//        DDLogVerbose(@"%@", drivesResult);
//    }
    [request release];

    //----------------------------------------------------------------------
    return drivesResult;
}


@end
