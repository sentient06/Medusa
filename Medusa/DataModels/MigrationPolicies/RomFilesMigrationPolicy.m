//
//  RomFilesToRomFilesMigrationPolicy.m
//  Medusa
//
//  Created by Gian2 on 16/09/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
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

#import "RomFilesMigrationPolicy.h"
#import "EmulatorsEntityModel.h"
#import "FileManager.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_INFO;
//------------------------------------------------------------------------------

@implementation RomFilesMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error {
    DDLogInfo(@"Migrating Rom file");
    // Create a new object for the model context

    NSManagedObject * newObject =
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName]
                                  inManagedObjectContext:[manager destinationContext]];
    
    [newObject setValue:[sInstance valueForKey:@"checksum"] forKey:@"checksum"];
    [newObject setValue:[sInstance valueForKey:@"comments"] forKey:@"comments"];

    // Emulator from string to int:
 
    NSString * emulatorString = [sInstance valueForKey:@"emulator"];
    if ([emulatorString isEqualToString:@"vMac"]) {
        [newObject setValue:[NSNumber numberWithInt:vMacStandard] forKey:@"emulatorType"];
    } else if ([emulatorString isEqualToString:@"Sheepshaver"]) {
        [newObject setValue:[NSNumber numberWithInt:Sheepshaver] forKey:@"emulatorType"];
    } else if ([emulatorString isEqualToString:@"Basilisk"]) {
        [newObject setValue:[NSNumber numberWithInt:BasiliskII] forKey:@"emulatorType"];
    }
    
    // Path from string to alias:
    NSString * oldPath     = [sInstance valueForKey:@"filePath"];
    NSString * escapedPath = [oldPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData   * fileAlias   = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
    
    [newObject setValue:fileAlias forKey:@"fileAlias"];

    // Validity of file:
    NSString * fileCheck = [FileManager resolveAlias:fileAlias];
    if ([fileCheck isEqualTo:nil]) {
        [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"fileMissing"];
        DDLogWarn(@"Path: %@ (missing)", oldPath);
    } else {
        DDLogInfo(@"Path: %@", oldPath);
    }
    
    // File size:
    NSData * data = [NSData dataWithContentsOfFile:oldPath];
    int fileSize = (int) [data length];
    [newObject setValue:[NSNumber numberWithInt:fileSize] forKey:@"fileSize"];
    
    // The rest look the same:
    [newObject setValue:[sInstance valueForKey:@"modelName"] forKey:@"modelName"];
    [newObject setValue:[sInstance valueForKey:@"romCategory"] forKey:@"romCategory"];
    [newObject setValue:[sInstance valueForKey:@"romCondition"] forKey:@"romCondition"];
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    return YES;
}

@end
