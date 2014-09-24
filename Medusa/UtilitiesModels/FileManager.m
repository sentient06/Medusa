//
//  FileManager.m
//  Medusa
//
//  Created by Gian2 on 09/06/2014.
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

#import "FileManager.h"
#import "RomFilesEntityModel.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_OFF;
//------------------------------------------------------------------------------

@implementation FileManager

+ (NSData *)createBookmarkFromUrl:(NSURL *)filePath {

    FSRef fsFile, fsOriginal;
    AliasHandle aliasHandle;
    NSString * fileOriginalPath = [[filePath absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    OSStatus status = FSPathMakeRef((unsigned char*)[fileOriginalPath cStringUsingEncoding: NSUTF8StringEncoding], &fsOriginal, NULL);
    NSAssert(status == 0, @"FSPathMakeRef fsHome failed");
    status = FSPathMakeRef((unsigned char*)[fileOriginalPath cStringUsingEncoding: NSUTF8StringEncoding], &fsFile, NULL);
    NSAssert(status == 0, @"FSPathMakeRef failed");
    OSErr err = FSNewAlias(&fsOriginal, &fsFile, &aliasHandle);
    NSAssert(err == noErr, @"FSNewAlias failed");
    NSData * aliasData = [NSData dataWithBytes: *aliasHandle length: GetAliasSize(aliasHandle)];
    
    DDLogVerbose(@"Data: %@", aliasData);
    
    return aliasData;
}

+ (void)resolveBookmarksInObjectContext:(NSManagedObjectContext *)currentContext {

    NSArray      * entitiesToCheck  = [[NSArray alloc] initWithObjects:@"RomFiles", @"DiskFiles", nil];
    NSEnumerator * entityEnumerator = [entitiesToCheck objectEnumerator];
    NSString     * entityName;

    while (entityName = [entityEnumerator nextObject]) {
        
        NSError             * error;
        NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity    = [ NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
        [request setEntity:entity];
        [request setReturnsObjectsAsFaults:NO];
        NSArray * results = [currentContext executeFetchRequest:request error:&error];
        NSEnumerator * rowEnumerator = [results objectEnumerator];
        RomFilesEntityModel * object;
        
        while (object = [rowEnumerator nextObject]) {
            NSData * aliasData = [object fileAlias];
            NSString * currentPath = [self resolveAlias:aliasData];
//            if ([currentPath isEqualToString:@""]) {
            if ([currentPath isEqualTo:nil]) {
                [object setFileMissing:[NSNumber numberWithBool:YES]];
            }
        }
        
        [request release];
        
    }
    
    [entitiesToCheck release];
    
}

+ (NSString *)resolveAlias:(NSData *)aliasData {
    NSUInteger aliasLen = [aliasData length];
    if (aliasLen > 0) {
        FSRef fsFile, fsOriginal;
        AliasHandle aliasHandle;
        OSErr err = PtrToHand([aliasData bytes], (Handle*)&aliasHandle, aliasLen);
        NSAssert(err == noErr, @"PtrToHand failed");
        Boolean changed;
        err = FSResolveAlias(&fsOriginal, aliasHandle, &fsFile, &changed);
        if (err == noErr) {
            char pathC[2*1024];
            OSStatus status = FSRefMakePath(&fsFile, (UInt8*) &pathC, sizeof(pathC));
            NSAssert(status == 0, @"FSRefMakePath failed");
            return [NSString stringWithCString: pathC encoding: NSUTF8StringEncoding];
        }
    }
    return nil; //@"";
}

@end
