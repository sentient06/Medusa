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

#import "RomController.h"
#import "RomFilesEntityModel.h" //Model that handles all Rom-Files-Entity-related objects.
#import "EmulatorsEntityModel.h"
#import "NSData+MD5.h"
#import "FileManager.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation RomController

@synthesize currentRomObject;

/*!
 * @abstract Checks if file is of a valid format.
 */
+ (BOOL)validateFile:(NSString *)filePath {
    
    if (![[[filePath pathExtension] lowercaseString] isEqualTo:@"rom"])
        return NO;
    
    NSString * kind = nil;
    NSURL    * url = [NSURL fileURLWithPath:[filePath stringByExpandingTildeInPath]];

    LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);

    NSArray * fileKinds = [[[NSArray alloc]
        initWithObjects:
            @"Unix Executable File"
          , @"Document"
          , @"ROM Image"
          , nil
    ] autorelease];
    
    if ([fileKinds containsObject:kind])
         return YES;
    else return NO;
}

/*!
 * @abstract Extracts ROM file's checksum.
 */
- (uint32)extractChecksumForFile:(NSString *)filePath {

    NSData * data = [NSData dataWithContentsOfFile:filePath];
    fileSize = (int) [data length];
    Byte * byteData = (Byte *)malloc(fileSize);
    uint32 result;
    memcpy(byteData, [data bytes], fileSize);
    
//    NSNumber * size = [[NSNumber alloc] initWithUnsignedLong:fileSize/2^20];
    
    switch (fileSize / 1024) {
        case 64  : fileSize = rom64KB;  break;
        case 128 : fileSize = rom128KB; break;
        case 256 : fileSize = rom256KB; break;
        case 512 : fileSize = rom512KB; break;
        case 1024: fileSize = rom1MB;   break;
        case 2048: fileSize = rom2MB;   break;
        case 3072: fileSize = rom3MB;   break;
        case 4096: fileSize = rom4MB;   break;
        default:   fileSize = romNull;  break;
    }

    result = ntohl(*(uint32 *)byteData);
    free(byteData);
    // The ntohl() function converts the unsigned integer netlong from network byte order to host byte order.
    return result;
}

/*!
 * @method      parseSingleRomFileAndSave:inObjectContext:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (id)parseSingleRomFileAndSave:(NSString *)filePath
                inObjectContext:(NSManagedObjectContext *)currentContext {
    
    if (![RomController validateFile:filePath]) {
        DDLogInfo(@"File did not pass validation for ROM.");
        return nil;
    } else {
        DDLogInfo(@"Parsing ROM file.");
        uint32 intChecksum = [self extractChecksumForFile:filePath];
        NSData * data = [NSData dataWithContentsOfFile:filePath];
        NSString * md5Hash = [data MD5];
    
        BOOL success = YES;
        
        if (intChecksum != 0) {
           
            checksum = [NSString stringWithFormat: @"%X", intChecksum];
            DDLogVerbose(@"Checksum = 0x%@", checksum);
            //----------------------------------------------------------------------
            // Core-data part:
            
            NSError * error;
            
            NSString * escapedPath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData   * fileAlias   = [FileManager createBookmarkFromUrl:[NSURL URLWithString:escapedPath]];
            
            NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
            NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"RomFiles" inManagedObjectContext:currentContext];
            NSPredicate         * predicate = [ NSPredicate
                predicateWithFormat: @"fileAlias = %@ OR checksum = %@",
                fileAlias, checksum
            ];
            
            [request setEntity:entity];
            [request setPredicate: predicate];
            NSInteger resultCount = [currentContext countForFetchRequest:request error:&error];

            [request release];
                    
            if (resultCount > 0) {
                DDLogVerbose(@"This ROM file is duplicated!");
                return nil;
            }        
            
            [self getDetailsForChecksum:intChecksum AndMD5:md5Hash];

//            if (emulator == EmulatorUnsupported) {
//                DDLogError(@"Unsupported file");
//                return NO;
//            }
            
            //----------------------------------------------------------------------
            
            RomFilesEntityModel * managedObject = [
                NSEntityDescription
                insertNewObjectForEntityForName: @"RomFiles"
                         inManagedObjectContext: currentContext
            ];
            
            /// Here we have all the fields to be inserted.
            [managedObject setFileAlias    : fileAlias];
            [managedObject setChecksum     : checksum];
            [managedObject setModelName    : macModel];
            [managedObject setComments     : comments];
            [managedObject setRomCondition : [NSNumber numberWithInt:fileCond]];
            [managedObject setRomCategory  : [NSNumber numberWithInt:category]];
            [managedObject setFileSize     : [NSNumber numberWithInt:fileSize]];
            [managedObject setEmulatorType : [NSNumber numberWithInt:emulator]];

            //----------------------------------------------------------------------
            
            DDLogVerbose(@"Saving...");

            if (![currentContext save:&error]) {
                DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
                DDLogVerbose(@"Check 'drop rom view' subclass.");
                success = NO;
            }
            
            if (success) {
                currentRomObject = managedObject;
                return managedObject;
            }
            
            //----------------------------------------------------------------------

        }

        macModel = nil;
        comments = nil;
        emulator = -1;
    
    }

    return nil;

}

/*!
 * @method      parseRomFileAndSave:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (void)parseRomFileAndSave:(NSString *)filePath {
    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    [self parseSingleRomFileAndSave:filePath inObjectContext:managedObjectContext];
}

/*!
 * @method      parseRomFilesAndSave:
 * @abstract    Reads a list of files and inserts into the data model.
 */
- (void)parseRomFilesAndSave:(NSArray *)filesList {
    
    for (int i = 0; i < [filesList count]; i++) {
        
        if ([[filesList objectAtIndex:i] isKindOfClass:[NSURL class]]) {
            [self parseRomFileAndSave:[[filesList objectAtIndex:i] path]];
        } else {
            [self parseRomFileAndSave:[filesList objectAtIndex:i]];
        }
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
- (void)getDetailsForChecksum:(uint32)intChecksum AndMD5:(NSString *)md5Hash {
    
    //http://guides.macrumors.com/68k
    
    emulator = EmulatorUnsupported;
    category = OldWorldROM;
    short macMd[5];
    
    switch( intChecksum ) {
        //------------------------------------------------
        // 64 KB
        case 0x28BA61CE:
            macModel = @"Macintosh 128";
            comments = @"First Macintosh ever made.\nThis ROM can't be used on emulation.";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltClassic;
            break;
            
        case 0x28BA4E50:
            macModel = @"Macintosh 512K";
            comments = @"Second Macintosh ever made.\nThis ROM can't be used on emulation.";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltClassic;
            break;
        //------------------------------------------------
        // 128 KB
        case 0x4D1EEEE1:
            macModel = @"Macintosh Plus v1 Lonely Hearts";
            comments = @"This ROM was buggy and had 2 revisions!\nvMac can't boot from it.\nThe second revision (v3) is more recommended.";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacPlus;
            break;
            
        case 0x4D1EEAE1:
            macModel = @"Macintosh Plus v2 Lonely Heifers";
            comments = @"This ROM was the first revision and still had some bugs.\nv3 is more recommended.";
            emulator = vMacStandard;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacPlus;
            break;
            
        case 0x4D1F8172:
            macModel = @"Macintosh Plus v3 Loud Harmonicas";
            comments = @"Best Mac Plus ROM, second revision from the original.\nGood for vMac.";
            emulator = vMacStandard;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacPlus;
            break;
        //------------------------------------------------
        // 256 KB
        case 0x97851DB6:
            macModel = @"Macintosh II v1";
            comments = @"First Mac II ROM, had a memory problem\nThis one is rare!\nvMac won't boot it.";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacII;
            break;
        case 0xB2E362A8:
            macModel = @"Macintosh SE";
            comments = @"";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacSE;
            break;
        case 0x9779D2C4:
            macModel = @"Macintosh II v2";
            comments = @"Mac II ROM's revision";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacII;
            break;
        case 0xB306E171:
            macModel = @"Macintosh SE FDHD";
            comments = @"FDHD stands for 'Floppy Disk High Density'\nThis mac was later called Macintosh SE Superdrive";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacSE;
            break;
        case 0x97221136:
            macModel = @"Macintosh IIx, IIcx, SE/30";
            comments = @"'32-bit dirty' ROM, since it has code using 24-bit addressing.\n'x' stands for the 68030 processor family, 'c' stands for 'compact'\nApple used 'SE/30' to avoid the acronym 'SEx'";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltMacIIx;
            macMd[1] = gestaltMacIIcx;
            macMd[2] = gestaltMacSE030;
            break;
        case 0x96CA3846:
            macModel = @"Macintosh Portable";
            comments = @"One of the first 'laptops'!";
            emulator = EmulatorUnsupported;
            fileCond = UnsupportedRom;
            macMd[0] = gestaltPortable;
            break;
        case 0xA49F9914:
            macModel = @"Macintosh Classic (XO)";
            comments = @"From Mac Classic with XO ROMDisk: It has the ability to boot from ROM by holding down cmd+opt+x+o at startup.\nLimited support in Basilisk II.";//Classic emulation is broken on Basilisk
            emulator = vMacModelCompilationAndBasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacClassic;
            break;
        case 0x96645F9C:
            macModel = @"Macintosh PowerBook 100";
            comments = @"";
            emulator = EmulatorUnsupported;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBook100;
            break;
        //------------------------------------------------
        // 512 KB
        case 0x4147DD77:
            macModel = @"Macintosh IIfx";
            comments = @"Known as Stealth, Blackbird, F-16, F-19, Four Square, IIxi, Zone 5 and Weed-Whacker.\nEmulation requires FPU and AppleTalk is not supported.";
            emulator = BasiliskII;
            fileCond = NoAppleTalkAndFPURequired;
            macMd[0] = gestaltMacIIfx;
            break;
        case 0x350EACF0:
            macModel = @"Macintosh LC"; // Pizza box
            comments = @"AppleTalk is not supported in Basilisk.";
            emulator = NoAppleTalk;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacLC;
            break;
        case 0x3193670E: //messy checksum
            macModel = @"Macintosh Classic II";
            comments = @"Emulation may require the FPU and AppleTalk may not be supported.";
            emulator = BasiliskII;
            fileCond = NoAppleTalkAndFPURequired;
            macMd[0] = gestaltClassicII;
            break;            
        case 0x368CADFE:
            macModel = @"Macintosh IIci";
            comments = @"In Basilisk, FPU must be enabled and appleTalk is not supported.\nThis is a 32-bit clean ROM.";
            emulator = BasiliskII;
            fileCond = NoAppleTalkAndFPURequired;
            macMd[0] = gestaltMacIIci;
            break;
        case 0x36B7FB6C:
            macModel = @"Macintosh IIsi";
            comments = @"In Basilisk, AppleTalk is not supported.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacIIsi;
            break;
        case 0x35C28F5F: // Pizza box too
            macModel = @"Mac LC II or Performa 400/405/410/430"; //IIci?
            comments = @"In Basilisk, AppleTalk is not supported.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacLCII;
            break;
            //--------------------------------------------
        case 0x35C28C8F: // Very strange didn't find it
                         // Model was called IIxi, which seems non-existent
            macModel = @"Macintosh IIx";
            comments = @"AppleTalk may not be supported.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacIIx;
            break;
        case 0x4957EB49: 
            macModel = @"Mac IIvx (Brazil) or IIvi/Performa 600";
            comments = @"Mac IIvx was the last of Mac II series.\nAppleTalk may not be supported for emulation.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacIIx;
            macMd[1] = gestaltMacIIvi;
            macMd[2] = gestaltPerforma600;
            break;
        //------------------------------------------------
        // 1024 KB
        // Things get messy here
        case 0x420DBFF3:
            macModel = @"Quadra 700/900 or PowerBook 140/170";
            comments = @"AppleTalk is not supported on Basilisk II.\nThis is the worst known 1MB ROM.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacQuadra700;
            macMd[1] = gestaltMacQuadra900;
            macMd[2] = gestaltPowerBook140;
            macMd[3] = gestaltPowerBook170;
            break;
        case 0x3DC27823:
            macModel = @"Macintosh Quadra 950";
            comments = @"AppleTalk is not supported on Basilisk II.";
            emulator = BasiliskII;
            fileCond = NoAppleTalk;
            macMd[0] = gestaltMacQuadra950;
            break;
        case 0x49579803: // Very strange didn't find it, called IIvx
                         // 0x49579803 (different size)
            macModel = @"Macintosh IIvx ?"; //Again? Brazil?
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacIIvx;
            break;
        case 0xE33B2724:
            macModel = @"Powerbook 160/165/165c/180/180c";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBook160;
            macMd[1] = gestaltPowerBook165;
            macMd[2] = gestaltPowerBook165c;
            macMd[3] = gestaltPowerBook180;
            macMd[4] = gestaltPowerBook180c;
            break;
        case 0xECFA989B:
            macModel = @"Powerbook Duo 210/230/250";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBookDuo210;
            macMd[1] = gestaltPowerBookDuo230;
            macMd[2] = gestaltPowerBookDuo250;
            break;
        case 0xEC904829:
            macModel = @"Macintosh LCIII";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacLCIII;
            break;
        case 0xECBBC41C:
            macModel = @"Macintosh LCIII/LCIII+ or Performa 460";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacLCIII;
            macMd[1] = gestaltPerforma46x;
            break;
        case 0xECD99DC0:
            macModel = @"Macintosh Color Classic / Performa 250";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacColorClassic;
            macMd[1] = gestaltPerforma250;
            break;
        case 0xF1A6F343:
            macModel = @"Quadra/Centris 610 or 650";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltQuadra610;
            macMd[1] = gestaltQuadra650;
            break;
        case 0xF1ACAD13:
            macModel = @"Quadra/Centris 610 or 650 or 800";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltQuadra610;
            macMd[1] = gestaltQuadra650;
            macMd[2] = gestaltQuadra800;
            macMd[3] = gestaltMacCentris610;
            macMd[4] = gestaltMacCentris650;
            break;
        case 0x0024D346:
            macModel = @"Powerbook Duo 270C";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBookDuo270c;
            break;
        case 0xEDE66CBD:
            macModel = @"Color Classic II, LC 550, Performa 275/550/560, Mac TV";//Maybe Performa 450-550";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPerforma550;
            macMd[1] = gestaltMacTV;
            break;
        case 0xFF7439EE:
            macModel = @"LC 475/575 Quadra 605 Performa 475/476/575/577/578";
            comments = @"Codename Aladdin";
            emulator = BasiliskII;
            fileCond = NormalCondition; //FPURequired; //?
            macMd[0] = gestaltMacLC475;
            macMd[1] = gestaltMacLC575;
            macMd[2] = gestaltMacQuadra605;
            break;
        case 0x015621D7:
            macModel = @"Powerbook Duo 280 or 280C";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBookDuo280;
            macMd[1] = gestaltPowerBookDuo280c;
            break;
        case 0x06684214:
            macModel = @"LC/Quadra/Performa 630";
            comments = @"Codename Crusader";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacQuadra630;
            break;
        case 0xFDA22562:
            macModel = @"Powerbook 150";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltPowerBook150;
            break;
        case 0x064DC91D:
            macModel = @"LC/Performa 580/588";
            comments = @"AppleTalk is reported to work in Basilisk II.";
            emulator = BasiliskII;
            fileCond = NormalCondition;
            macMd[0] = gestaltMacLC580;
            break;
        //------------------------------------------------
        // 2MB and 3MB ROMs
        // 2048 KB
        case 0xB6909089: // or 0x68LC040 ?
            macModel = @"PowerBook 520/520c/540/540c";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
//            macMd[0] = gestaltPowerBook520;
//            macMd[1] = gestaltPowerBook520c;
//            macMd[2] = gestaltPowerBook540;
//            macMd[3] = gestaltPowerBook540c;
            break;
        case 0x5BF10FD1:
            macModel = @"Macintosh Quadra 660av or 840av";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
//            macMd[0] = gestaltQuadra660AV;
//            macMd[1] = gestaltQuadra840AV;
            break;
        case 0x4D27039C:
            macModel = @"PowerBook 190 or 190cs";
            emulator = Sheepshaver;
            fileCond = NormalCondition; //fpu required???
//            macMd[0] = gestaltPowerBook190;
            break;
        //------------------------------------------------
        // 4MB
        case 0x9FEB69B3:
            macModel = @"Power Mac 6100/7100/8100";
            emulator = Sheepshaver;
            fileCond = OldWorldROM;
            break;
        case 0x9C7C98F7:
            macModel = @"Workgroup Server 9150 80MHz";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x9B7A3AAD:
            macModel = @"Power Mac 7100 (newer)";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x63ABFD3F:
            macModel = @"Power Mac & Performa 5200/5300/6200/6300";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x9B037F6F:
            macModel = @"Workgroup Server 9150 120MHz";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x83C54F75:
            macModel = @"PowerBook 2300 & PB5x0 PPC Upgrade";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x9630C68B:
            macModel = @"Power Mac 7200/7500/8500/9500 v2";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x96CD923D:
            macModel = @"Power Mac 7200/7500/8500/9500 v1";
            comments = @"Runs on Sheepshaver";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x6F5724C0:
            macModel = @"PowerM ac/Performa 6400";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x83A21950:
            macModel = @"PowerBook 1400, 1400cs";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x6E92FE08:
            macModel = @"Power Mac 6500";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x960E4BE9:
            macModel = @"Power Mac 7300/7600/8600/9600 (v1)";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x960FC647:
            macModel = @"Power Mac 8600 or 9600 (v2)";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x78F57389:
            macModel = @"Power Mac G3 (v3)";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0x79D68D63:
            macModel = @"Power Mac G3 desktop";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0xCBB01212:
            macModel = @"PowerBook G3 Wallstreet";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        case 0xB46FFB63:
            macModel = @"PowerBook G3 Wallstreet PDQ";
            emulator = Sheepshaver;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // New World ROM
        default:
            
            DDLogVerbose(@"New World!");
            DDLogVerbose(@"old: %d, new: %d, undefined: %d", OldWorldROM, NewWorldROM, NoCategory);
            
            category = NewWorldROM;
            emulator = Sheepshaver;

            if ([md5Hash isEqualToString:@"e0fc03faa589ee066c411b4603e0ac89"]) {
                macModel = @"Mac OS ROM 1.1";
            } else
            if ([md5Hash isEqualToString:@"17b134a0d837518498c06579aa4ff053"]) {
                macModel = @"Mac OS ROM 1.1.2";
            } else
            if ([md5Hash isEqualToString:@"133ef27acf2f360341870f212c7207d7"]) {
                macModel = @"Mac OS ROM 1.1.5";
            } else
            if ([md5Hash isEqualToString:@"3756f699eadaabf0abf8d3322bed70e5"]) {
                macModel = @"Mac OS ROM 1.2";
                comments = @"From Mac OS 8.5.1 Bundle:\nPower Macintosh G3 (Blue and White) or..\nMacintosh Server G3 (Blue and White).";
            } else
            if ([md5Hash isEqualToString:@"483233f45e8ca33fd2fbe5201f06ac18"]) {
                macModel = @"Mac OS ROM 1.2.1";
                comments = @"Version from the iMac Update 1.1.\nAlso bundled on Mac OS 8.5.1 (Colors iMac 266 MHz Bundle).";
            } else
            if ([md5Hash isEqualToString:@"1bf445c27513dba473cca51219184b07"]) {
                macModel = @"Mac OS ROM 1.4";
                comments = @"Rom extracted from Mac OS 8.6\nor Colors iMac 333 MHz Bundle\nor Power Macintosh G3 (Blue and White) Mac OS 8.6 Bundle";
            } else
            if ([md5Hash isEqualToString:@"be65e1c4f04a3f2881d6e8de47d66454"]) {
                macModel = @"Mac OS ROM 1.6";
                comments = @"Very popular ROM extracted from the Mac OS ROM Update 1.0.\nAlso available on the Macintosh PowerBook G3 Series 8.6 Bundle.";
            } else
            if ([md5Hash isEqualToString:@"dd26176882d14c39219aca668d7e97cb"]) {
                macModel = @"Mac OS ROM 1.7.1";
            } else
            if ([md5Hash isEqualToString:@"02350bfe27c4dea1d2c13008efb3a036"]) {
                macModel = @"Mac OS ROM 1.8.1";
            } else
            if ([md5Hash isEqualToString:@"722fe6481b4d5c04e005e5ba000eb00e"]) {
                macModel = @"Mac OS ROM 2.3.1";
            } else
            if ([md5Hash isEqualToString:@"4bb3e019c5d7bfd5f3a296c13ad7f08f"]) {
                macModel = @"Mac OS ROM 2.5.1";
                comments = @"ROM from the Mac OS 8.6 bundled on Power Mac G4 (AGP).\nThis was rare before being seeded as a torrent (still difficult to get, though).";
            } else
            if ([md5Hash isEqualToString:@"d387acd4503ce24e941f1131433bbc0f"]) {
                macModel = @"Mac OS ROM 3.0";
            } else
            if ([md5Hash isEqualToString:@"9e990cde6c30a3ab916c1390b29786c7"]) {
                macModel = @"Mac OS ROM 3.1.1";
                comments = @"Mac OS 9.0 bundled on iBook or\nMac OS 9.0 bundled on Power Mac G4";
            } else
            if ([md5Hash isEqualToString:@"bbfbb4c884741dd75e03f3de67bf9370"]) {
                macModel = @"Mac OS ROM 3.2.1";
            } else
            if ([md5Hash isEqualToString:@"386ea1c81730f9b06bfc2e6c36be8d59"]) {
                macModel = @"Mac OS ROM 3.5";
                comments = @"Mac OS 9.0.2 installed on PowerBook";
            } else
            if ([md5Hash isEqualToString:@"????????????????????????????????"]) {
                macModel = @"Mac OS ROM 3.6";
                comments = @"Mac OS 9.0.3 bundled on iMac";
            } else
            if ([md5Hash isEqualToString:@"8f388ccf6f96c58bda5ae83d207ca85a"]) {
                macModel = @"Mac OS ROM 3.7";
                comments = @"Mac OS 9.0.4 Retail/Software Update or\nMac OS 9.0.4 installed on PowerBook";
            } else
            if ([md5Hash isEqualToString:@"3f182e059a60546f93114ed3798d5751"]) {
                macModel = @"Mac OS ROM 3.8";
                comments = @"Extracted from Ethernet Update 1.0.\nVery clever!";
            } else
            if ([md5Hash isEqualToString:@"bf9f186ba2dcaaa0bc2b9762a4bf0c4a"]) {
                macModel = @"Mac OS ROM 4.6.1";
                comments = @"Mac OS 9.0.4 installed on iMac (2000)";
            } else
            if ([md5Hash isEqualToString:@"????????????????????????????????"]) {
                macModel = @"Mac OS ROM 4.9.1";
                comments = @"Mac OS 9.0.4 installed on Power Mac G4";
            } else
            if ([md5Hash isEqualToString:@"52ea9e30d59796ce8c4822eeeb0f543e"]) {
                macModel = @"Mac OS ROM 5.2.1";
                comments = @"Mac OS 9.0.4 installed on Power Mac G4 Cube";
            } else
            if ([md5Hash isEqualToString:@"????????????????????????????????"]) {
                macModel = @"Mac OS ROM 5.3.1";
                comments = @"Mac OS 9.0.4 installed on iBook";
            } else
            if ([md5Hash isEqualToString:@"????????????????????????????????"]) {
                macModel = @"Mac OS ROM 5.5.1";
                comments = @"Mac OS 9.0.4 installed on Power Mac G4";
            } else
            if ([md5Hash isEqualToString:@"5e9a959067e1261d19427f983dd10162"]) {
                macModel = @"Mac OS ROM 6.1";
                comments = @"Mac OS 9.1 Update";
            } else
            if ([md5Hash isEqualToString:@"19d596fc3028612edb1553e4d2e0f345"]) {
                macModel = @"Mac OS ROM 6.7.1";
                comments = @"Mac OS 9.1 installed on Power Mac G4";
            } else
            if ([md5Hash isEqualToString:@"14cd0b3d8a7e022620b815f4983269ce"]) {
                macModel = @"Mac OS ROM 7.5.1";
                comments = @"Mac OS 9.1 installed on iMac (2001)";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"28a08b4d5d5e4ab113c5fc1b25955a7c"]) {
                macModel = @"Mac OS ROM 7.8.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"1486fe0b293e23125c00b9209435365c"]) {
                macModel = @"Mac OS ROM 7.9.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"6fc4679862b2106055b1ce301822ffeb"]) {
                macModel = @"Mac OS ROM 8.3.1";
                comments = @"Mac OS 9.2 installed on Power Mac G4 (QuickSilver)";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"f97d43821fea307578697a64b1705f8b"]) {
                macModel = @"Mac OS ROM 8.4";
                comments = @"Mac OS 9.2.1 Update";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"d81574f35e97a658eab99df52529251e"]) {
                macModel = @"Mac OS ROM 8.6.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"97db5e70d05ab7568d8a1f7ddd3b901a"]) {
                macModel = @"Mac OS ROM 8.7";
                comments = @"Mac OS 9.2.2 Update";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"65e3bc1fee886bbe1aabe0faa4b8cda2"]) {
                macModel = @"Mac OS ROM 8.9.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"66210b4f71df8a580eb175f52b9d0f88"]) {
                macModel = @"Mac OS ROM 9.0.1";
                comments = @"Mac OS 9.2.2 installed on iMac (2001)";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"c5f7aaaf28d7c7eac746e9f26b183816"]) {
                macModel = @"Mac OS ROM 9.1.1";
                comments = @"From iMac G4 Restore CD.";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"13889037360fe1567c7e7f89807453b0"]) {
                macModel = @"Mac OS ROM 9.2.1f2";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"b36a5f1d814291a22457adfa2331b379"]) {
                macModel = @"Mac OS ROM 9.5.1";
                comments = @"Mac OS 9.2.2 installed on iMac (17-inch Flat Panel)";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"3c08de22aeaa7d7fdb14df848fbaa90d"]) {
                macModel = @"Mac OS ROM 9.6.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"e74f8c6bb52a641b856d821be7a65275"]) {
                macModel = @"Mac OS ROM 9.7.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"4e8d07f8e0d4af6d06336688013972c3"]) {
                macModel = @"Mac OS ROM 9.8.1";

                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"1fb3de4d87889c26068dd88779dc20e2"]) {
                macModel = @"Mac OS ROM 10.1.1";
                emulator = EmulatorUnsupported;
            } else
            if ([md5Hash isEqualToString:@"48fd7a428aaebeaec2dea347795a4910"]) {
                macModel = @"Mac OS ROM 10.2.1";
                emulator = EmulatorUnsupported;
            } else {
                macModel = @"Unsupported ROM size.";
                comments = @"Size should be 64KB, 128KB, 256KB, 512KB, 1MB, 2MB, 3MB or 4MB.";
                emulator = EmulatorUnsupported;
                category = NoCategory;
            }

        break;

    }
    
    if (category == NewWorldROM) {
        checksum = md5Hash;
    }
    
    if (comments == nil) {
        comments = @"";
    }
    
    if (emulator == Sheepshaver) {
        macMd[0] = gestaltPowerMac9500;
    }
    
    if (emulator == EmulatorUnsupported) {
        fileCond = UnsupportedRom;
    }
    
    DDLogVerbose(@"fileDetails .. %@", macModel);
    DDLogVerbose(@"comments ..... %@", comments);
    DDLogVerbose(@"romCondition . %d", emulator);

}


@end
