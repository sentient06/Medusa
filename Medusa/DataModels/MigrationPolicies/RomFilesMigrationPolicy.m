//
//  RomFilesToRomFilesMigrationPolicy.m
//  Medusa
//
//  Created by Gian2 on 16/09/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

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

//- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance
//                                    entityMapping:(NSEntityMapping *)mapping
//                                          manager:(NSMigrationManager *)manager
//                                            error:(NSError **)error {
//    
//}

//FUNCTION($entityPolicy, "emulatorFromString:" , $source.emulator)
/*
 - (NSNumber *)emulatorFromString:(NSString *)emulator {
 NSLog(@"Alright!");
 if ([emulator isEqualToString:@"vMac"])
 return [NSNumber numberWithInt:vMacStandard];
 else if ([emulator isEqualToString:@"Sheepshaver"])
 return [NSNumber numberWithInt:Sheepshaver];
 else if ([emulator isEqualToString:@"Basilisk"])
 return [NSNumber numberWithInt:BasiliskII];
 else
 return [NSNumber numberWithInt:EmulatorUnsupported];
 }
 
 //FUNCTION($entityPolicy, "aliasFromPath:" , $source.filePath)
 - (NSData *)aliasFromPath:(NSString *)filePath {
 NSLog(@"%@", filePath);
 NSString * escapedPath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 NSData   * fileAlias   = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
 return fileAlias;
 }
 
 //FUNCTION($entityPolicy, "validAliasFromPath:" , $source.filePath)
 - (NSNumber *)validAliasFromPath:(NSString *)filePath {
 NSLog(@"%@", filePath);
 NSString * escapedPath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 NSData   * fileAlias   = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
 NSString * fileCheck = [FileManager resolveAlias:fileAlias];
 if ([fileCheck isEqualTo:nil])
 return [NSNumber numberWithBool:YES];
 else
 return [NSNumber numberWithBool:NO];
 }
 */
/**/

@end
