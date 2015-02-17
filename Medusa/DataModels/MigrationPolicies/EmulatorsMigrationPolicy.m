//
//  EmulatorsMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 16/02/2015.
//  Copyright (c) 2015 Giancarlo Mariot. All rights reserved.
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

#import "EmulatorsMigrationPolicy.h"
//import "EmulatorsEntityModel.h"
#import "FileManager.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation EmulatorsMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error {
    DDLogInfo(@"Migrating Emulator");

    // Create a new object for the model context
    
    NSManagedObject * newObject = [
        NSEntityDescription
            insertNewObjectForEntityForName:[mapping destinationEntityName]
                     inManagedObjectContext:[manager destinationContext]
    ];
    
//    DDLogVerbose(@"New data will be stored here: %@", newObject);
    
    for(id key in [[[sInstance entity] attributesByName] allKeys]) {
        NSLog(@"key=%@ value=%@", key, [sInstance valueForKey:key]);
        [newObject setValue:[sInstance valueForKey:key] forKey:key];
    }

//    [newObject setValue:[sInstance valueForKey:@"family"] forKey:@"family"];
//    [newObject setValue:[sInstance valueForKey:@"maintained"] forKey:@"maintained"];
//    [newObject setValue:[sInstance valueForKey:@"name"] forKey:@"name"];
//    [newObject setValue:[sInstance valueForKey:@"readablePath"] forKey:@"readablePath"];
//    [newObject setValue:[sInstance valueForKey:@"unixPath"] forKey:@"unixPath"];
//    [newObject setValue:[sInstance valueForKey:@"useCount"] forKey:@"useCount"];
//    [newObject setValue:[sInstance valueForKey:@"version"] forKey:@"version"];
    
    @try {
        [newObject setValue:[sInstance valueForKey:@"appMissing"] forKey:@"appMissing"];
    }
    @catch (NSException * e) {
        DDLogVerbose(@"No key for appMissing");
        @try {
            [newObject setValue:[sInstance valueForKey:@"appAlias"] forKey:@"appAlias"];
        }
        @catch (NSException * e) {
            DDLogVerbose(@"No key for appAlias");
            NSString * escapedPath = [[sInstance valueForKey:@"readablePath"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData * fileAlias = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
            [newObject setValue:fileAlias forKey:@"appAlias"];
            
            @try {
                NSString * resolvedFilePath = [FileManager resolveAlias:fileAlias];
                if (resolvedFilePath == nil)
                    [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"appMissing"];
                else
                    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"appMissing"];
            }
            @catch (NSException * e) {
                DDLogVerbose(@"No key for appMissing");
            }
            
        }
    }
    
//    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"missing"];
    
    DDLogVerbose(@"\n======================\nNew object:\n%@\n======================\n", newObject);
    
    BOOL validated = NO;
    
    @try {
        validated = [self performCustomValidationForEntityMapping:mapping manager:manager error:error];
    }
    @catch (NSException * e) {
        DDLogVerbose(@"Error on validating: %@", error);
    }
    @finally {
        DDLogVerbose(@"Validation result: %@", validated ? @"Fine" : @"Fucked");
    }
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];

    return YES;
}

//- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance
//                                    entityMapping:(NSEntityMapping *)mapping
//                                          manager:(NSMigrationManager *)manager
//                                            error:(NSError **)error {
//    NSError *superError = nil;
//    return [super createRelationshipsForDestinationInstance:dInstance entityMapping:mapping manager:manager error:&superError];
//}




@end
