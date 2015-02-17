//
//  MigrationAssistant.m
//  Medusa
//
//  Created by Gian2 on 12/02/2015.
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

#import "MigrationAssistant.h"
#import "AppDelegate.h"
#import "EmulatorsEntityModel.h"
#import "FileManager.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation MigrationAssistant

+ (void)executeMigrationChangesFor:(NSString *)mapping
            InManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {

    if ([mapping isEqual: @"MappingModel-1.2.0.2-1.2.0.3"]) [MigrationAssistant
        createEmulatorAliasesInManagedObjectContext:managedObjectContext
    ];
//    if ([mapping isEqual: @"MappingModel-1.2.0.3-1.2.0.4"]) [MigrationAssistant
//        createEmulatorAppMissingInManagedObjectContext:managedObjectContext
//    ];

//    NSError * error = nil;
//    if (![managedObjectContext save:&error]) {
//        DDLogError(@"Whoops, couldn't save: %@\n\n%@", [error localizedDescription], [error userInfo]);
//        DDLogVerbose(@"Check 'App Delegate' class, saveCloneVirtualMachine");
//    }
}
    
+ (void)createEmulatorAliasesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    DDLogVerbose(@"Creating alias");
    NSError * error;
    
    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"Emulators" inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entity];
    
    NSInteger resultCount = [managedObjectContext countForFetchRequest:request error:&error];
    if (resultCount > 0) {
        NSArray * emulatorsResult = [managedObjectContext executeFetchRequest:request error:&error];
        for (id dataElement in emulatorsResult) {
            DDLogVerbose(@"Name: %@", [dataElement name]);
            DDLogVerbose(@"Path: %@", [dataElement readablePath]);
            NSString * escapedPath = [[dataElement readablePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            DDLogVerbose(@"Escaped path: %@", escapedPath);
            NSData * fileAlias = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
            [dataElement setAppAlias:fileAlias];
        }
        
    }
    [request release];
}

+ (void)createEmulatorAppMissingInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    DDLogVerbose(@"Checking alias");
    NSError * error;
    
    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"Emulators" inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entity];
    
    NSInteger resultCount = [managedObjectContext countForFetchRequest:request error:&error];
    if (resultCount > 0) {
        NSArray * emulatorsResult = [managedObjectContext executeFetchRequest:request error:&error];
        for (id dataElement in emulatorsResult) {
//            DDLogVerbose(@"Element: %@", dataElement);
            DDLogVerbose(@"Name: %@", [dataElement name]);
            NSString * resolvedFilePath = [FileManager resolveAlias:[dataElement appAlias]];
            DDLogVerbose(@"Resolved path: %@", resolvedFilePath==nil? @"yes" : @"no");
            if (resolvedFilePath == nil)
                [dataElement setAppMissing:[NSNumber numberWithBool:YES]];
            else
                [dataElement setAppMissing:[NSNumber numberWithBool:NO]];
        }
        
    }
    [request release];
}

@end
