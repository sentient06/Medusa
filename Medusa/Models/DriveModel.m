//
//  DriveModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 22/09/2013.
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

#import "DriveModel.h"
#import "DrivesModel.h" //Model that handles all Rom-Files-Entity-related objects.

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation DriveModel

@synthesize currentDriveObject;

/*!
 * @method      parseSingleDriveFileAndSave:inObjectContext:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (id)parseSingleDriveFileAndSave:(NSString *)filePath
                inObjectContext:(NSManagedObjectContext *)currentContext {
    // Here we add the new Drive's attributes.
    
//    Mount Point :	/ (maybe not)
//    Capacity :    2 GB (xxx,xxx Bytes)
// 	  Format :      Mac OS Extended (Journaled)
//    Available :   1 GB (xxx,xxx Bytes)
//    Owners Enabled : Yes (maybe not)
//    Used :        1 GB (xxx,xxx Bytes)
//    Number of Folders : 2,843
//    Number of Files :   1,586
    // Locked?
    // OS?
    BOOL success = YES;
    
//    NSString * pathExtension = [filePath pathExtension];    
    
    //----------------------------------------------------------------------
    // Core-data part:
    
    NSError * error;
    
    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"Drives" inManagedObjectContext:currentContext];
    NSPredicate         * predicate = [ NSPredicate
        predicateWithFormat: @"filePath = %@",
        filePath
    ];
    
    [request setEntity:entity];
    [request setPredicate: predicate];
    NSInteger resultCount = [currentContext countForFetchRequest:request error:&error];
    
    [request release];
    
    if (resultCount > 0) {
        DDLogVerbose(@"This disk file is duplicated!");
        return nil;
    }
    
    [self readDiskFileFrom:filePath];
    
    //----------------------------------------------------------------------        
    
    DrivesModel * managedObject = [
        NSEntityDescription
            insertNewObjectForEntityForName: @"Drives"
            inManagedObjectContext: currentContext
    ];
    
    [managedObject setFilePath : filePath];
    [managedObject setFileName : fileName];
    [managedObject setBootable : [NSNumber numberWithBool:bootable]];
    [managedObject setCapacity : [NSNumber numberWithUnsignedInteger:capacity]];
    [managedObject setFormat   : [NSNumber numberWithUnsignedInteger:diskFormat]];
    [managedObject setSize     : [NSNumber numberWithUnsignedInteger:diskSize]];
    
    //----------------------------------------------------------------------
    
    DDLogVerbose(@"Saving...");
    
    if (![currentContext save:&error]) {
        DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
        DDLogVerbose(@"Check 'drop rom view' subclass.");
        success = NO;
    }
    
    if (success) {
        currentDriveObject = managedObject;
        return managedObject;
    }
    
    //----------------------------------------------------------------------

    fileName   = nil;
    diskFormat = -1;
    capacity   = -1;
    bootable   = NO;
    diskSize   = -1;
    
    return nil;
}

/*!
 * @method      parseDriveFileAndSave:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (void)parseDriveFileAndSave:(NSString *)filePath {    
    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    [self parseSingleDriveFileAndSave:filePath inObjectContext:managedObjectContext];
}

/*!
 * @method      parseRomFilesAndSave:
 * @abstract    Reads a list of files and inserts into the data model.
 */
- (void)parseDriveFilesAndSave:(NSArray *)filesList {
    for (int i = 0; i < [filesList count]; i++) {
        [self parseDriveFileAndSave:[filesList objectAtIndex:i]];
    }
}

- (BOOL)checkIfDiskImageIsBootable:(NSString *)filePath {
    
    // Refer to:
    // https://en.wikipedia.org/wiki/HFS_Plus#Design
    // for details.
    // Actually, we must check 400 bytes into sector 0, the rest doesn't matter.
    
    NSString * bootableDriveBootBlock = @""
    "4C4B6000 00864418 00000653 79737465 6D000000 00000000 00000646 696E6465 72000000 00000000"
    "0000074D 61637342 75670000 00000000 00000C44 69736173 73656D62 6C657200 00000D53 74617274"
    "55705363 7265656E 00000646 696E6465 72000000 00000000 00000943 6C697062 6F617264 00000000"
    "0000000A 00140000 43000000 80000002 00004A78 028E6B46 207802AE 32280008 7CFE5446 303B603C"
    "6758B240 66F40C01 00766210 207802A6 D1FAFFD4 A05721F8 02A60118 584F2E0F 6138323B 60224A40"
    "6704323B 60242078 02AE4EF0 10007062 A9C90075 02760178 037A067C 00000A44 090E0F1C 30E61D96"
    "0B820A52 11AE336E 203E41FA FF0E43F8 0AD87010 A02E41FA FF1243F8 02E07010 A02E41FA FF5643F8"
    "097021C9 096C7010 A02E303A FF58A06D 303AFF50 A06C2047 31780210 0016A00F 665442A8 00124268"
    "001CA207 66402868 005E2168 005A0030 6710217C 4552494B 001C7001 A2606626 A015554F A9954A5F"
    "6B1A594F 2F3C626F 6F743F3C 0002A9A0 201F6712 584F2640 20534ED0 702B3F00 2047A00E 301F4E75";
    
    // I know it is dumb, but I like it to be readable.
    bootableDriveBootBlock = [bootableDriveBootBlock stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Pure C ahead.
    
    FILE * f;
    int bufferSize = 400;
    unsigned char buffer[bufferSize];
    unsigned long n;
    char firstBytes[bufferSize*2+1];
    f = fopen([filePath UTF8String], "r");
    n = fread(buffer, bufferSize, 1, f);
    for (int c=0; c<bufferSize; c++)
        if (c==0) snprintf(firstBytes, bufferSize*2+1, "%.2X", (int)buffer[c]);
        else      snprintf(firstBytes, bufferSize*2+1, "%s%.2X", firstBytes, (int)buffer[c]);
    fclose(f);
    firstBytes[bufferSize*2] = 0;

    // That's enough.
    
    NSString * finalResult = [[NSString alloc] initWithFormat:@"%s", firstBytes];
    
    if ([bootableDriveBootBlock isEqualTo:finalResult]) {
        DDLogCVerbose(@"Image is bootable");
        return YES;
    } else {
        DDLogCVerbose(@"Image is NOT bootable:\n%@\n\n%@\n", bootableDriveBootBlock, finalResult);
        return NO;
    }

}

- (void)readDiskFileFrom:(NSString *)filePath {
//    NSString * fileName;
//    int diskFormat;
//    int capacity;
//    BOOL bootable;
    
    fileName = [filePath lastPathComponent];
    bootable = [self checkIfDiskImageIsBootable:filePath];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError       * error       = nil;
    NSDictionary  * attributes  = [fileManager attributesOfItemAtPath:filePath error:&error];

    diskSize   = [attributes fileSize];
    diskFormat = formatUnknown;
    
    // hdiutil imageinfo <image>
    // hdiutil imageinfo -plist <image>

    NSTask * task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"imageinfo", @"-plist", filePath, nil]];
    [task setStandardOutput:[NSPipe pipe]];
    [task setStandardError:[task standardOutput]];
    [task launch];
    NSData       * plistData = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
    NSDictionary * plist = [NSPropertyListSerialization propertyListWithData:plistData options:0 format:nil error:&error];
    
    if(!plist) {
        DDLogError(@"Error: %@", error);
    } else {
        
        int totalPartitions = 0;
        NSUInteger partitionType = formatUnknown;
       
        for (id partitionElement in [[plist objectForKey:@"partitions"] objectForKey:@"partitions"]) {
            if ([partitionElement respondsToSelector:@selector(objectForKey:)]) {
                NSDictionary * fileSystems = [partitionElement objectForKey:@"partition-filesystems"];
                if (fileSystems) {
                    
                    NSArray * expectedFileSystems = [
                        [NSArray alloc] initWithObjects:
                          @""
                        , @"LFS"
                        , @"MFS"
                        , @"HFS"
                        , @"HFS+"
                        , @"ISO9660"
                        , @"FAT12"
                        , nil
                    ];
                    
                    //formatLisaFS  = Must test
                    //formatMFS     = MFS
                    //formatHFS     = HFS
                    //formatHFSPlus = HFS+
                    //formatISO9660 = ISO9660
                    //formatFAT     = FAT12
                    //formatOther   = 7, // Other FS
                    //formatUnknown = 8, // Unknown FS
                    //formatMisc    = 9  // Partitioned with different FS
                    
                    for (id fileSystem in fileSystems) {
                        totalPartitions++;
                        DDLogVerbose(@"key: %@, value: %@", fileSystem, [fileSystems objectForKey:fileSystem]);
                        
                        NSUInteger indexFS = [expectedFileSystems indexOfObject:fileSystem];

                        if (totalPartitions > 1 && partitionType != indexFS) partitionType = formatMisc;
                        else
                        if (indexFS) partitionType = indexFS;
                        
                        //formatLisaFS  = 1, // Lisa File-system
                        //formatMFS     = 2, // Macintosh File-system
                        //formatHFS     = 3, // Hyerarquical File-system
                        //formatHFSPlus = 4, // Hyerarquical File-system Plus
                        //formatISO9660 = 5, // ISO 9660 - CD/DVD ROM
                        //formatFAT     = 6, // FAT 16, FAT 32
                        //formatOther   = 7, // Other FS
                        //formatUnknown = 8, // Unknown FS
                        //formatMisc    = 9  // Partitioned with different FS
                        
                    }
                }
            }
        }
        
        DDLogVerbose(@"%d partitions found", totalPartitions);
        DDLogVerbose(@"Partitions type is %u", partitionType);
        
        diskFormat = partitionType;

    }

}

@end
