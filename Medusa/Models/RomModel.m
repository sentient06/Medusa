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
#import "RomFilesEntityModel.h" //Model that handles all Rom-Files-Entity-related objects.

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation RomModel

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
    
    return ntohl(*(uint32 *)byteData);
}

/*!
 * @method      parseSingleRomFileAndSave:inObjectContext:
 * @abstract    Reads a single file and inserts into the data model.
 */
- (id)parseSingleRomFileAndSave:(NSString *)filePath
                inObjectContext:(NSManagedObjectContext *)currentContext {
    
    if (![RomModel validateFile:filePath]) {
        return nil;
    } else {
        uint32 intChecksum = [self extractChecksumForFile:filePath];
    
        BOOL success = YES;
        
        if (intChecksum != 0) {
           
            checksum = [NSString stringWithFormat: @"%X", intChecksum];
            NSLog(@"Checksum = 0x%@", checksum);
            //----------------------------------------------------------------------
            // Core-data part:
            
            NSError * error;
            
            NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
            NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"RomFiles" inManagedObjectContext:currentContext];
            NSPredicate         * predicate = [ NSPredicate
                predicateWithFormat: @"filePath = %@ OR checksum = %@",
                filePath, checksum
            ];
            
            [request setEntity:entity];
            [request setPredicate: predicate];
            NSInteger resultCount = [currentContext countForFetchRequest:request error:&error];

            [request release];
                    
            if (resultCount > 0) {
                DDLogVerbose(@"This ROM file is duplicated!");
                return nil;
            }        
            
            [self getDetailsForChecksum:intChecksum];

            if (emulator == EmulatorUnsupported) {
                
                
//                switch([size intValue]) {
//                    case 65536: //64KB
//                    case 131072: //128KB
//                    case 262144: //256KB
//                        break;
//                    case 524288: //512KB
//                        emulator = BasiliskII;
//                        fileCond = NoAppleTalk;
//                        break;
//                    case 1048576: //1MB
//                    case 2097152: //2MB
//                    case 3145728: //3MB
//                    case 4194304: //4MB
//                    default:
//                        macModel = @"Unsupported ROM size.";
//                        comments = [NSString stringWithFormat: @"%d", [size intValue]];
//                        emulator = Unsupported;
//                        break;
//                }

                
                
                DDLogError(@"Unsupported file");
                return NO;
            }
            
            //----------------------------------------------------------------------
            
            RomFilesEntityModel * managedObject = [
                NSEntityDescription
                insertNewObjectForEntityForName: @"RomFiles"
                         inManagedObjectContext: currentContext
            ];
            
            /// Here we have all the fields to be inserted.
            [managedObject setFilePath     : filePath];
            [managedObject setChecksum     : checksum];
            [managedObject setModelName    : macModel];
            [managedObject setComments     : comments];
            [managedObject setRomCondition : [NSNumber numberWithInt:emulator]];
            [managedObject setRomCategory  : [NSNumber numberWithInt:category]];
            [managedObject setFileSize     : [NSNumber numberWithInt:fileSize]];
            
            [managedObject setMac68kOld:[NSNumber numberWithBool:NO]];
            [managedObject setMac68kNew:[NSNumber numberWithBool:NO]];
            [managedObject setMacPPCOld:[NSNumber numberWithBool:NO]];
            [managedObject setMacPPCNew:[NSNumber numberWithBool:NO]];
            
            // These are necessary to be used in interface bindings
            switch (fileSize) {
                case rom64KB:
                case rom128KB:
                case rom256KB:
                case rom512KB:
                    [managedObject setMac68kOld:[NSNumber numberWithBool:YES]];
                break;
                case rom1MB:
                    [managedObject setMac68kNew:[NSNumber numberWithBool:YES]];
                break;
                case rom2MB:
                case rom3MB:
                case rom4MB:
                    [managedObject setMacPPCOld:[NSNumber numberWithBool:YES]];
                break;
            }
            
            switch (emulator) {
                    
                case vMacStandard:
                case vMacModelCompilation:
                    [managedObject setEmulator:@"vMac"];
                break;
                case BasiliskII:
                    [managedObject setEmulator:@"Basilisk"];
                break;
                case vMacStandardAndBasiliskII:
                    [managedObject setEmulator:@"Basilisk"];
                break;
                case Sheepshaver:
                    [managedObject setEmulator:@"Sheepshaver"];
                break;

            }

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
- (void)getDetailsForChecksum:(uint32)intChecksum {
    
//    BOOL sheepshaverEnabled = YES; //[[NSUserDefaults standardUserDefaults] boolForKey:@"sheepshaverEnabled"];
    
//    NSString * romPath = [[NSString alloc] initWithString:filePath];
    
//    NSData * data   = [NSData dataWithContentsOfFile:romPath];
//    NSUInteger len  = [data length];
//    Byte * byteData = (Byte*)malloc(len);
//    memcpy(byteData, [data bytes], len);
    
//    NSNumber * size = [[NSNumber alloc] initWithUnsignedLong:len/2^20];
    
//    switch (len / 1024) {
//        case 64  : romSize = rom64KB;  break;
//        case 128 : romSize = rom128KB; break;
//        case 256 : romSize = rom256KB; break;
//        case 512 : romSize = rom512KB; break;
//        case 1024: romSize = rom1MB;   break;
//        case 2048: romSize = rom2MB;   break;
//        case 3072: romSize = rom3MB;   break;
//        case 4096: romSize = rom4MB;   break;
//        default:   romSize = romNull;  break;
//    }
    
    //http://guides.macrumors.com/68k
    
    switch( intChecksum ) {
        //------------------------------------------------
        // 64 KB
        case 0x28BA61CE:
            macModel = @"Macintosh 128";
            comments = @"First Macintosh ever made.\nThis ROM can't be used on emulation.";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
            
        case 0x28BA4E50:
            macModel = @"Macintosh 512K";
            comments = @"Second Macintosh ever made.\nThis ROM can't be used on emulation.";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        //------------------------------------------------
        // 128 KB
        case 0x4D1EEEE1:
            macModel = @"Macintosh Plus v1 Lonely Hearts";
            comments = @"This ROM was buggy and had 2 revisions!\nvMac can't boot from it.\nThe second revision (v3) is more recommended.";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
            
        case 0x4D1EEAE1:
            macModel = @"Macintosh Plus v2 Lonely Heifers";
            comments = @"This ROM was the first revision and still had some bugs.\nv3 is more recommended.";
            emulator = vMacStandard;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
            
        case 0x4D1F8172:
            macModel = @"Macintosh Plus v3 Loud Harmonicas";
            comments = @"Best Mac Plus ROM, second revision from the original.\nGood for vMac.";
            emulator = vMacStandard;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // 256 KB
        case 0x97851DB6:
            macModel = @"Macintosh II v1";
            comments = @"First Mac II ROM, had a memory problem\nThis one is rare!\nvMac won't boot it.";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0xB2E362A8:
            macModel = @"Macintosh SE";
            comments = @"";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0x9779D2C4:
            macModel = @"Macintosh II v2";
            comments = @"Mac II ROM's revision";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0xB306E171:
            macModel = @"Macintosh SE FDHD";
            comments = @"FDHD stands for 'Floppy Disk High Density'\nThis mac was later called Macintosh SE Superdrive";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0x97221136:
            macModel = @"Macintosh IIx, IIcx, SE/30";
            comments = @"'32-bit dirty' ROM, since it has code using 24-bit addressing.\n'x' stands for the 68030 processor family, 'c' stands for 'compact'\nApple used 'SE/30' to avoid the acronym 'SEx'";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0x96CA3846:
            macModel = @"Macintosh Portable";
            comments = @"One of the first 'laptops'!";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = UnsupportedRom;
            break;
        case 0xA49F9914:
            macModel = @"Macintosh Classic (XO)";
            comments = @"From Mac Classic with XO ROMDisk: It has the ability to boot from ROM by holding down cmd+opt+x+o at startup.\nLimited support in Basilisk II.";//Classic emulation is broken on Basilisk
            emulator = vMacModelCompilationAndBasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0x96645F9C:
            macModel = @"Macintosh PowerBook 100";
            comments = @"";
            emulator = EmulatorUnsupported;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // 512 KB
        case 0x4147DD77:
            macModel = @"Macintosh IIfx";
            comments = @"Known as Stealth, Blackbird, F-16, F-19, Four Square, IIxi, Zone 5 and Weed-Whacker.\nEmulation requires FPU and AppleTalk is not supported.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalkAndFPURequired;
            break;
        case 0x350EACF0:
            macModel = @"Macintosh LC"; // Pizza box
            comments = @"AppleTalk is not supported in Basilisk.";
            emulator = NoAppleTalk;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0x3193670E: //messy checksum
            macModel = @"Macintosh Classic II";
            comments = @"Emulation may require the FPU and AppleTalk may not be supported.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalkAndFPURequired;
            break;            
        case 0x368CADFE:
            macModel = @"Macintosh IIci";
            comments = @"In Basilisk, FPU must be enabled and appleTalk is not supported.\nThis is a 32-bit clean ROM.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalkAndFPURequired;
            break;
        case 0x36B7FB6C:
            macModel = @"Macintosh IIsi";
            comments = @"In Basilisk, AppleTalk is not supported.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
        case 0x35C28F5F: // Pizza box too
            macModel = @"Mac LC II or Performa 400/405/410/430"; //IIci?
            comments = @"In Basilisk, AppleTalk is not supported.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
            //--------------------------------------------
        case 0x35C28C8F: // Very strange didn't find it
                         // Model was called IIxi, which seems non-existent
            macModel = @"Macintosh IIx";
            comments = @"AppleTalk may not be supported.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
        case 0x4957EB49: 
            macModel = @"Mac IIvx (Brazil) or IIvi/Performa 600";
            comments = @"Mac IIvx was the last of Mac II series.\nAppleTalk may not be supported for emulation.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
        //------------------------------------------------
        // 1024 KB
        // Things get messy here
        case 0x420DBFF3:
            macModel = @"Quadra 700/900 or PowerBook 140/170";
            comments = @"AppleTalk is not supported on Basilisk II.\nThis is the worst known 1MB ROM.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
        case 0x3DC27823:
            macModel = @"Macintosh Quadra 950";
            comments = @"AppleTalk is not supported on Basilisk II.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NoAppleTalk;
            break;
        case 0x49579803: // Very strange didn't find it, called IIvx
                         // 0x49579803 (different size)
            macModel = @"Macintosh IIvx ?"; //Again? Brazil?
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xE33B2724:
            macModel = @"Powerbook 160/165/165c/180/180c";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xECFA989B:
            macModel = @"Powerbook 210/230/250";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xEC904829:
            macModel = @"Macintosh LC III";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xECBBC41C:
            macModel = @"Macintosh LCIII/LCIII+ or Performa 460";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xECD99DC0:
            macModel = @"Macintosh Color Classic / Performa 250";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xF1A6F343:
            macModel = @"Quadra/Centris 610 or 650";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xF1ACAD13:
            macModel = @"Quadra/Centris 610 or 650 or 800";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0x0024D346:
            macModel = @"Powerbook Duo 270C";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xEDE66CBD:
            macModel = @"Color Classic II, LC 550, Performa 275/550/560, Mac TV";//Maybe Performa 450-550";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xFF7439EE:
            macModel = @"LC 475/575 Quadra 605 Performa 475/476/575/577/578";
            comments = @"Codename Aladdin";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition; //FPURequired; //?
            break;
        case 0x015621D7:
            macModel = @"Powerbook Duo 280 or 280C";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0x06684214:
            macModel = @"LC/Quadra/Performa 630";
            comments = @"Codename Crusader";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0xFDA22562:
            macModel = @"Powerbook 150";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        case 0x064DC91D:
            macModel = @"LC/Performa 580/588";
            comments = @"AppleTalk is reported to work in Basilisk II.";
            emulator = BasiliskII;
            category = OldWorld68k;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // 2MB and 3MB ROMs
        // 2048 KB
        case 0xB6909089: // or 0x68LC040 ?
            macModel = @"PowerBook 520/520c/540/540c";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x5BF10FD1:
            macModel = @"Macintosh Quadra 660av or 840av";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x4D27039C:
            macModel = @"PowerBook 190 or 190cs";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition; //fpu required???
            break;
        //------------------------------------------------
        // 4MB
        case 0x9FEB69B3:
            macModel = @"Power Mac 6100/7100/8100";
            emulator = Sheepshaver;
            category = OldWorld68k;
            fileCond = PPCOldWorld;
            break;
        case 0x9C7C98F7:
            macModel = @"Workgroup Server 9150 80MHz";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x9B7A3AAD:
            macModel = @"Power Mac 7100 (newer)";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x63ABFD3F:
            macModel = @"Power Mac & Performa 5200/5300/6200/6300";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x9B037F6F:
            macModel = @"Workgroup Server 9150 120MHz";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x83C54F75:
            macModel = @"PowerBook 2300 & PB5x0 PPC Upgrade";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x9630C68B:
            macModel = @"Power Mac 7200/7500/8500/9500 v2";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x96CD923D:
            macModel = @"Power Mac 7200/7500/8500/9500 v1";
            comments = @"Runs on Sheepshaver";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x6F5724C0:
            macModel = @"PowerM ac/Performa 6400";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x83A21950:
            macModel = @"PowerBook 1400, 1400cs";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x6E92FE08:
            macModel = @"Power Mac 6500";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x960E4BE9:
            macModel = @"Power Mac 7300/7600/8600/9600 (v1)";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x960FC647:
            macModel = @"Power Mac 8600 or 9600 (v2)";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x78F57389:
            macModel = @"Power Mac G3 (v3)";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0x79D68D63:
            macModel = @"Power Mac G3 desktop";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0xCBB01212:
            macModel = @"PowerBook G3 Wallstreet";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        case 0xB46FFB63:
            macModel = @"PowerBook G3 Wallstreet PDQ";
            emulator = Sheepshaver;
            category = PPCOldWorld;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // 4MB New World ROM
        case 0x3C434852:
            macModel = @"Mac OS ROM 1.6";
            comments = @"Extracted from the \"MacOS ROM Update 1.0\". Very popular."; // be65e1c4f04a3f2881d6e8de47d66454
            emulator = Sheepshaver;
            category = PPCNewWorld;
            fileCond = NormalCondition;
            break;
        //------------------------------------------------
        // Unknown
        default:
            macModel = @"Unknown ROM";
            category = Unknown;
            emulator = EmulatorUnsupported;
            break;

    }
    
    // be65e1c4f04a3f2881d6e8de47d66454
    
    if (comments == nil) {
        comments = @"";
    }
    
    DDLogVerbose(@"fileDetails .. %@", macModel);
    DDLogVerbose(@"comments ..... %@", comments);
    DDLogVerbose(@"romCondition . %d", emulator);

}


@end
