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
#import "DrivesModel.h"

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

@end
