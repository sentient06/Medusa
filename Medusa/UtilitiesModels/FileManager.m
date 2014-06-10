//
//  FileManager.m
//  Medusa
//
//  Created by Gian2 on 09/06/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import "FileManager.h"
#import "RomFilesEntityModel.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
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
    
//    NSLog(@"Data: %@", aliasData);
    
    return aliasData;
}

+ (void)resolveBookmarksInObjectContext:(NSManagedObjectContext *)currentContext {

    //----------------------------------------------------------------------
    // ROM files:
    
    NSError * error;
    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"RomFiles" inManagedObjectContext:currentContext];
    [request setEntity:entity];
    [request setReturnsObjectsAsFaults:NO];
    NSArray * results = [currentContext executeFetchRequest:request error:&error];
    NSEnumerator * rowEnumerator = [results objectEnumerator];
    RomFilesEntityModel * object;

    while (object = [rowEnumerator nextObject]) {
        NSData * aliasData = [object fileAlias];
        NSString * currentPath = [self resolveAlias:aliasData];
        if ([currentPath isEqualToString:@""]) {
            [object setFileMissing:[NSNumber numberWithBool:YES]];
        }
    }
    
    [request release];
    
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
    return @"";
}

@end
