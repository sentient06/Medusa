//
//  DropAllView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 20/09/2013.
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

#import "DropAllView.h"
#import "RomModel.h"
#import "DriveModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation DropAllView

@synthesize reportField;

/**
 * Iterates directories to parse files.
 */
-(void)iterateDirectory:(NSString *)currentDirectory {

    directoriesParsed++;

    DDLogVerbose(@"Parsing folder" );
    
    NSFileManager * fileManager = [[[NSFileManager alloc] init] autorelease];
    NSURL         * directoryURL = [NSURL fileURLWithPath:[currentDirectory stringByExpandingTildeInPath]];
    NSArray       * keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator * enumerator = [
        fileManager
        enumeratorAtURL:directoryURL
        includingPropertiesForKeys:keys
        options:0
        errorHandler:^(NSURL * url, NSError * error) {
            // Handle the error.
            // Return YES if the enumeration should continue after the error.
            return YES;
        }
    ];
    
    for (NSURL * url in enumerator) {

        //Check if is a folder:
        BOOL isDir;
        NSFileManager * fileManager = [[NSFileManager alloc] init];
        [fileManager fileExistsAtPath:[url absoluteString] isDirectory:&isDir];
        [fileManager release];
        
        if (!isDir) [self parseFile:[url relativePath]];
        else directoriesParsed++;
        
    }
}

/**
 * Parses not-directory files.
 */
-(void)parseFile:(NSString *)currentFile {
    NSURL * url = [NSURL fileURLWithPath:[currentFile stringByExpandingTildeInPath]];
    if ([[url lastPathComponent] isEqualToString:@".DS_Store"]) return;
    
    filesParsed++;
    NSString * kind = nil;
    LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
    DDLogVerbose(@"Kind: %@, url: %@", kind, [url relativePath]); //[url absoluteString] );
    
    NSArray * acceptedExtensions = [[NSArray alloc] initWithObjects: @"hfv", @"dsk", @"dmg", @"img", @"image", @"iso", nil];
    
    if ([acceptedExtensions containsObject:[[url pathExtension] lowercaseString]]) {
        DriveModel * driveObject = [[DriveModel alloc] init];
        [driveObject parseDriveFileAndSave:[url relativePath]];
        [driveObject release];
        disksParsed++;
    } else {
        if ([kind isEqualToString:@"Unix Executable File"] || [kind isEqualToString:@"Document"] ){
            RomModel * romObject = [[RomModel alloc] init];
            [romObject parseRomFileAndSave:[url relativePath]];
            [romObject release];
            romsParsed++;
        }
    }

}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    directoriesParsed = 0;
    filesParsed       = 0;
    romsParsed        = 0;
    disksParsed       = 0;
    filesRejected     = 0;
    depthReached      = 0;
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    
    // Get all pasteboard:
    NSArray * droppedFileUrls = [
        [sender draggingPasteboard] propertyListForType:NSFilenamesPboardType
    ];
    
    // Iterate objects:
    for (int i = 0; i < [droppedFileUrls count]; i++) {
        NSString * currentObject = [droppedFileUrls objectAtIndex:i];
        
        //Check if is a folder:
        BOOL isDir;
        NSFileManager * fileManager = [[NSFileManager alloc] init];
        [fileManager fileExistsAtPath:currentObject isDirectory:&isDir];
        [fileManager release];
        
        if (isDir)
            [self iterateDirectory:currentObject];
        else
            [self parseFile:currentObject];
        
    }
    
    DDLogVerbose(@"directories: %d, filesParsed: %d", directoriesParsed, filesParsed);

    if (reportField) {
//        [reportField setStringValue:[NSString stringWithFormat:@""
//            "  Files parsed: %d\n"
//            "Folders parsed: %d\n"
//            "   Roms parsed: %d\n"
//            "   Disk images: %d\n"
//            "Rejected files: %d\n"
//          , filesParsed - directoriesParsed
//          , directoriesParsed
//          , romsParsed
//          , disksParsed
//          , romsParsed + disksParsed - filesParsed        
//        ]];
        [reportField setStringValue:[NSString stringWithFormat:@"%d files parsed.", filesParsed]];
        
        [NSTimer
            scheduledTimerWithTimeInterval:5
                                    target:self
                                  selector:@selector(clearReportField)
                                  userInfo:nil
                                   repeats:YES
        ];
        
    }
    
    return YES;
    
}

- (void)clearReportField {
    [reportField setStringValue:@""];
}

@end
