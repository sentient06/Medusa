//
//  RomModel.m
//  ROMan / Medusa
//
//  Created by Giancarlo Mariot on 03/09/2013.
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

#import "RomModel.h"
#import "FileHandler.h"
#import "RomFilesModel.h" //Model that handles all Rom-Files-Entity-related objects.

@implementation RomModel

@synthesize currentRomObject;

/*!
 * @method      parseSingleRomFileAndSave:inObjectContext:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (id)parseSingleRomFileAndSave:(NSString *)filePath
                  inObjectContext:(NSManagedObjectContext *)currentContext {
    
     /*------------------------------------------------------------------*\
     
     If the code got this far, it means the file is a "Document" or a
     "Unix Executable File", which are the acceptable types of file to a
     ROM image. Here we must check the extension. It must be "rom" or
     nothing. After that we check the file binary data and find out if it
     is valid or not. If the file is not a ROM, it should be ignored.
     
     \*------------------------------------------------------------------*/
    
    BOOL success = YES;
    
    NSString * pathExtension = [filePath pathExtension];
    
    if ([[pathExtension lowercaseString] isEqualTo:@"rom"] ||
        [[pathExtension lowercaseString] isEqualTo:@""]
    ) {
        
        [self readRomFileFrom:filePath];
        
        //----------------------------------------------------------------------
        // Core-data part:
        
        NSError * error;
        
        NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"RomFiles" inManagedObjectContext:currentContext];
        NSPredicate         * predicate = [ NSPredicate
            predicateWithFormat: @"filePath = %@ OR modelName = %@",
            filePath, fileDetails
        ];
        
        [request setEntity:entity];
        [request setPredicate: predicate];
        NSInteger resultCount = [currentContext countForFetchRequest:request error:&error];

        [request release];
                
        if (resultCount > 0) {
            NSLog(@"This ROM file is duplicated!");
            return nil;
        }        
        
        //----------------------------------------------------------------------        
        
        RomFilesModel * managedObject = [
            NSEntityDescription
            insertNewObjectForEntityForName: @"RomFiles"
                     inManagedObjectContext: currentContext
        ];
        
        /// Here we have all the fields to be inserted.
        [managedObject setFilePath     : filePath];
        [managedObject setModelName    : fileDetails];
        [managedObject setComments     : comments];
        [managedObject setRomCondition : [NSNumber numberWithInt:romCondition]];
        
        switch (romCondition) {

            case PerfectSheepNew        :
            case PerfectSheepOld        :
                [managedObject setEmulator:@"Sheepshaver"];
                [managedObject setMac68k:[NSNumber numberWithBool:NO]];
                [managedObject setMacPPC:[NSNumber numberWithBool:YES]];
            break;

            case PerfectBasilisk        :
            case NoAppleTalk            :
            case FPURequired            :
            case NoAppleTalkFPURequired :
                [managedObject setEmulator:@"Basilisk"];
                [managedObject setMac68k:[NSNumber numberWithBool:YES]];
                [managedObject setMacPPC:[NSNumber numberWithBool:NO]];
            break;

        }

        //----------------------------------------------------------------------
        
        NSLog(@"Saving...");

        if (![currentContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            NSLog(@"Check 'drop rom view' subclass.");
            success = NO;
        }
        
        if (success) {
            currentRomObject = managedObject;
            return managedObject;
        }
        
        //----------------------------------------------------------------------

    } else {
        success = NO;
    }

    fileDetails  = nil;
    comments     = nil;
    romCondition = -1;
    
    return nil;  
    
}

/*!
 * @method      parseRomFilesAndSave:
 * @abstract    Reads a list of files and inserts into the data model.
 */
- (void)parseRomFilesAndSave:(NSArray *)filesList {
    
    //Must abstract all of this in a new class. -> Use CoreDataModel object.
    
    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    
    for (int i = 0; i < [filesList count]; i++) {
        [self parseSingleRomFileAndSave:[filesList objectAtIndex:i] inObjectContext:managedObjectContext];
        // bool checking?
    }

}

/*!
 * @method      readRomFileFrom:
 * @abstract    Reads file and checks if it is a valid ROM file.
 * http://www.jagshouse.com/rom.html
 * http://www.jagshouse.com/68kmacs.html
 * http://minivmac.sourceforge.net/mac68k.html
 * http://www.jagshouse.com/plusrom.html
 */
- (void)readRomFileFrom:(NSString *)filePath {
    
    BOOL sheepshaverEnabled = YES; //[[NSUserDefaults standardUserDefaults] boolForKey:@"sheepshaverEnabled"];
    
    NSString * romPath = [[NSString alloc] initWithFormat:filePath];
    
    NSData * data   = [NSData dataWithContentsOfFile:romPath];
    NSUInteger len  = [data length];
    Byte * byteData = (Byte*)malloc(len);
    
    memcpy(byteData, [data bytes], len);
    
    NSNumber * size = [[NSNumber alloc] initWithUnsignedLong:len/2^20];
    
    NSLog(@"Potential ROM file size: %@", size);
    
    switch( ntohl(*(uint32 *)byteData) ) {
            
        // 64 KB
        case 0x28BA61CE:
            fileDetails  = @"Mac 128K";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;
            
        case 0x28BA4E50:
            fileDetails  = @"Mac 512K";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;
            
        // 128 KB
        case 0x4D1EEEE1:
            fileDetails  = @"Mac Plus v1 Lonely Hearts";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;
            
        case 0x4D1EEAE1:
            fileDetails  = @"Mac Plus v2 Lonely Heifers";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;
            
        case 0x4D1F8172:
            fileDetails  = @"Mac Plus v3 Loud Harmonicas";
            comments     = @"Not supported by Basilisk II\nTry vMac instead!";
            romCondition = Unsupported;
            break;
            
        // 256 KB
        case 0xB2E362A8:
        case 0xB306E171:
            fileDetails  = @"Mac SE";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;

        case 0xA49F9914:
            fileDetails  = @"Mac Classic";
            comments     = @"Classic emulation is currently broken.";
            romCondition = Unsupported;
            break;

        case 0x97221136:
            fileDetails  = @"Mac IIcx";
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;

        case 0x9779D2C4:
        case 0x97851DB6:
            fileDetails  = @"Mac II"; //vMac
            comments     = @"Not supported by Basilisk II";
            romCondition = Unsupported;
            break;
            
        // 512 KB
        case 0x368CADFE:
            fileDetails  = @"Mac IIci";
            comments     = @"FPU must be enabled.\nAppleTalk is not supported.";
            romCondition = NoAppleTalkFPURequired;
            break;

        case 0x36B7FB6C:
            fileDetails  = @"Mac IIsi"; //test
            comments     = @"AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;

        case 0x4147DD77:
            fileDetails  = @"Mac IIfx"; //test
            comments     = @"FPU must be enabled.\nAppleTalk is not supported.";
            romCondition = NoAppleTalkFPURequired;
            break;

        case 0x35C28C8F:
            fileDetails  = @"Mac IIx"; //test
            comments     = @"AppleTalk may not be supported.";
            romCondition = NoAppleTalk;
            break;

        case 0x4957EB49:
            fileDetails  = @"Mac IIvi";
            comments     = @"AppleTalk may not be supported.";
            romCondition = NoAppleTalk;
            break;

        case 0x350EACF0:
            fileDetails  = @"Mac LC";
            comments     = @"AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;

        case 0x35C28F5F:
            fileDetails  = @"Mac LC II";
            comments     = @"AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;

        case 0x3193670E:
            fileDetails  = @"Mac Classic II"; //test
            comments     = @"May require the FPU.\nAppleTalk may not be supported.";
            romCondition = NoAppleTalkFPURequired;
            break;
            
        // 1024 KB
        case 0x49579803:
            fileDetails  = @"Mac IIvx";
            romCondition = PerfectBasilisk;
            break;

        case 0xECBBC41C:
            fileDetails  = @"Mac LC III";
            romCondition = PerfectBasilisk;
            break;

        case 0xECD99DC0:
            fileDetails  = @"Mac Color Classic";
            romCondition = PerfectBasilisk;
            break;

        case 0xFF7439EE:
            fileDetails  = @"Quadra 605 or LC/Performa 475/575"; //test
            romCondition = PerfectBasilisk;
            break;

        case 0xF1A6F343:
            fileDetails  = @"Quadra/Centris 610/650/800";
            romCondition = PerfectBasilisk;
            break;

        case 0xF1ACAD13:	// Mac Quadra 650
            fileDetails  = @"Quadra 650";
            romCondition = PerfectBasilisk;
            break;

        case 0x420DBFF3:
            fileDetails  = @"Quadra 700/900";
            comments     = @"AppleTalk is not supported.\nThis is the worst known 1MB ROM.";
            romCondition = NoAppleTalk;
            break;

        case 0x3DC27823:
            fileDetails  = @"Mac Quadra 950";
            comments     = @"AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;

        case 0xE33B2724:
            fileDetails  = @"Powerbook 165c"; //test
            romCondition = PerfectBasilisk;
            break;

        case 0x06684214:
            fileDetails  = @"LC/Quadra/Performa 630";
            romCondition = PerfectBasilisk;
            break;

        case 0x064DC91D:
            fileDetails  = @"Performa 580/588"; //test
            comments     = @"AppleTalk is reported to work.";
            romCondition = PerfectBasilisk;
            break;

        case 0xEDE66CBD:
            fileDetails  = @"Performa 450-550"; //maybe
            romCondition = PerfectBasilisk;
            break;
            
        default:
            
            fileDetails  = @"Unknown ROM";
            romCondition = Unsupported;
            
            switch([size intValue]) {
                case 16404:
                    fileDetails = @"Unsupported ROM size";
                    comments = @"Is this an Apple ][ ROM??";
                    break;

                case 972893:
                    
                    if (sheepshaverEnabled) {
                        fileDetails  = @"Power Mac (New World ROM)";
                        romCondition = PerfectSheepNew;
                    }else{
                        fileDetails = @"Unsupported ROM size";
                        comments = [NSString stringWithFormat: @"%d", [size intValue]];
                    }
                    
                    break;
                case 1048576:
                    break;
                case 524288:
                    fileDetails  = @"AppleTalk is not supported.";
                    romCondition = NoAppleTalk;
                    break;
                case 262144:
                    break;
                    
                case 2097172:
                    
                    if (sheepshaverEnabled) {
                        fileDetails  = @"Power Mac (Old World ROM)";
                        romCondition = PerfectSheepOld;
                    }else{
                        fileDetails = @"Unsupported ROM size";
                        comments = [NSString stringWithFormat: @"%d", [size intValue]];
                    }
                    
                    break;
                default:
                    fileDetails = @"Unsupported ROM size";
                    comments = [NSString stringWithFormat: @"%d", [size intValue]];
                    break;
            }
            break;
    }
    
    if (comments == nil) {
        comments = @"";
    }
    
    NSLog(@"fileDetails .. %@", fileDetails);
    NSLog(@"comments ..... %@", comments);
    NSLog(@"romCondition . %d", romCondition);
    
    [size release];    
    [romPath release];
}


@end
