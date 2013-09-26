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
            DDLogVerbose(@"This ROM file is duplicated!");
            return nil;
        }        
        
        [self readRomFileFrom:filePath];
        if (romCondition == Unsupported) {
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
        [managedObject setModelName    : fileDetails];
        [managedObject setComments     : comments];
        [managedObject setRomCondition : [NSNumber numberWithInt:romCondition]];
        [managedObject setRomSize      : [NSNumber numberWithInt:romSize]];
        
        [managedObject setMac68kOld:[NSNumber numberWithBool:NO]];
        [managedObject setMac68kNew:[NSNumber numberWithBool:NO]];
        [managedObject setMacPPCOld:[NSNumber numberWithBool:NO]];
        [managedObject setMacPPCNew:[NSNumber numberWithBool:NO]];
        
        // These are necessary to be used in interface bindings
        switch (romSize) {
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
        
        switch (romCondition) {

            case PerfectSheepNew        :
                [managedObject setEmulator:@"Sheepshaver"];
                [managedObject setMacPPCOld:[NSNumber numberWithBool:NO]];
                [managedObject setMacPPCNew:[NSNumber numberWithBool:YES]];
            break;
            case PerfectSheepOld        :
                [managedObject setEmulator:@"Sheepshaver"];
            break;

            case PerfectBasilisk:
            case NoAppleTalk:
            case FPURequired:
            case NoAppleTalkFPURequired:
                [managedObject setEmulator:@"Basilisk"];
            break;
                
            case PerfectVMac:
                [managedObject setEmulator:@"vMac"];
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

    } else {
        success = NO;
    }

    fileDetails  = nil;
    comments     = nil;
    romCondition = -1;
    
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
        [self parseRomFileAndSave:[filesList objectAtIndex:i]];
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
    
//    BOOL sheepshaverEnabled = YES; //[[NSUserDefaults standardUserDefaults] boolForKey:@"sheepshaverEnabled"];
    
    NSString * romPath = [[NSString alloc] initWithFormat:filePath];
    
    NSData * data   = [NSData dataWithContentsOfFile:romPath];
    NSUInteger len  = [data length];
    Byte * byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    NSNumber * size = [[NSNumber alloc] initWithUnsignedLong:len/2^20];
    
    switch ([size intValue] / 1024) {
        case 64  : romSize = rom64KB;  break;
        case 128 : romSize = rom128KB; break;
        case 256 : romSize = rom256KB; break;
        case 512 : romSize = rom512KB; break;
        case 1024: romSize = rom1MB;   break;
        case 2048: romSize = rom2MB;   break;
        case 3072: romSize = rom3MB;   break;
        case 4096: romSize = rom4MB;   break;
        default:   romSize = romNull;  break;
    }
    
    switch( ntohl(*(uint32 *)byteData) ) {
        //------------------------------------------------
        // 64 KB
        case 0x28BA61CE:
            fileDetails  = @"Macintosh 128";
            comments     = @"First Macintosh ever made.\nThis ROM can't be used on emulation.";
            romCondition = Unsupported;
            break;
            
        case 0x28BA4E50:
            fileDetails  = @"Macintosh 512K";
            comments     = @"Second Macintosh ever made.\nThis ROM can't be used on emulation.";
            romCondition = Unsupported;
            break;
        //------------------------------------------------
        // 128 KB
        case 0x4D1EEEE1:
            fileDetails  = @"Macintosh Plus v1 Lonely Hearts";
            comments     = @"This ROM was buggy and had 2 revisions!\nvMac can't boot from it.\nThe second revision (v3) is more recommended.";
            romCondition = Unsupported;
            break;
            
        case 0x4D1EEAE1:
            fileDetails  = @"Macintosh Plus v2 Lonely Heifers";
            comments     = @"This ROM was the first revision and still had some bugs.\nv3 is more recommended.";
            romCondition = PerfectVMac;
            break;
            
        case 0x4D1F8172:
            fileDetails  = @"Macintosh Plus v3 Loud Harmonicas";
            comments     = @"Best Mac Plus ROM, second revision from the original.\nGood for vMac.";
            romCondition = PerfectVMac;
            break;
        //------------------------------------------------
        // 256 KB
        case 0x97851DB6:
            fileDetails  = @"Macintosh II v1";
            comments     = @"First Mac II ROM, had a memory problem\nThis one is rare!\nvMac won't boot it.";
            romCondition = Unsupported;
            break;
        case 0xB2E362A8:
            fileDetails  = @"Macintosh SE";
            comments     = @"";
            romCondition = Unsupported;
            break;
        case 0x9779D2C4:
            fileDetails  = @"Macintosh II v2";
            comments     = @"Mac II ROM's revision";
            romCondition = Unsupported;
            break;
        case 0xB306E171:
            fileDetails  = @"Macintosh SE FDHD";
            comments     = @"FDHD stands for 'Floppy Disk High Density'\nThis mac was later called Macintosh SE Superdrive";
            romCondition = Unsupported;
            break;
        case 0x97221136:
            fileDetails = @"Macintosh IIx, IIcx, SE/30";
            comments = @"'32-bit dirty' ROM, since it has code using 24-bit addressing.\n'x' stands for the 68030 processor family, 'c' stands for 'compact'\nApple used 'SE/30' to avoid the acronym 'SEx'";
            romCondition = Unsupported;
            break;
        case 0x96CA3846:
            fileDetails  = @"Macintosh Portable";
            comments     = @"One of the first 'laptops'!";
            romCondition = Unsupported;
            break;
        case 0xA49F9914:
            fileDetails  = @"Macintosh Classic (XO)";
            comments     = @"From Mac Classic with XO ROMDisk: It has the ability to boot from ROM by holding down cmd+opt+x+o at startup.\nLimited support in Basilisk II.";//Classic emulation is broken on Basilisk
            romCondition = PerfectVMac;
            break;
        case 0x96645F9C:
            fileDetails  = @"Macintosh PowerBook 100";
            comments     = @"";
            romCondition = Unsupported;
            break;
        //------------------------------------------------
        // 512 KB
        case 0x4147DD77:
            fileDetails  = @"Macintosh IIfx";
            comments     = @"Known as Stealth, Blackbird, F-16, F-19, Four Square, IIxi, Zone 5 and Weed-Whacker.\nEmulation requires FPU and AppleTalk is not supported.";
            romCondition = NoAppleTalkFPURequired;
            break;
        case 0x350EACF0:
            fileDetails  = @"Macintosh LC"; // Pizza box
            comments     = @"AppleTalk is not supported in Basilisk.";
            romCondition = NoAppleTalk;
            break;
        case 0x3193670E: //messy checksum
            fileDetails  = @"Macintosh Classic II";
            comments     = @"Emulation may require the FPU and AppleTalk may not be supported.";
            romCondition = NoAppleTalkFPURequired;
            break;            
        case 0x368CADFE:
            fileDetails  = @"Macintosh IIci";
            comments     = @"In Basilisk, FPU must be enabled and appleTalk is not supported.\nThis is a 32-bit clean ROM.";
            romCondition = NoAppleTalkFPURequired;
            break;
        case 0x36B7FB6C:
            fileDetails  = @"Macintosh IIsi";
            comments     = @"In Basilisk, AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;
        case 0x35C28F5F: // Pizza box too
            fileDetails  = @"Mac LC II or Performa 400/405/410/430"; //IIci?
            comments     = @"In Basilisk, AppleTalk is not supported.";
            romCondition = NoAppleTalk;
            break;
            //--------------------------------------------
        case 0x35C28C8F: // Very strange didn't find it
                         // Model was called IIxi, which seems non-existent
            fileDetails  = @"Macintosh IIx";
            comments     = @"AppleTalk may not be supported.";
            romCondition = NoAppleTalk;
            break;
        case 0x4957EB49: 
            fileDetails  = @"Mac IIvx (Brazil) or IIvi/Performa 600";
            comments     = @"Mac IIvx was the last of Mac II series.\nAppleTalk may not be supported for emulation.";
            romCondition = NoAppleTalk;
            break;
        //------------------------------------------------
        // 1024 KB
        // Things get messy here
        case 0x420DBFF3:
            fileDetails  = @"Quadra 700/900 or PowerBook 140/170";
            comments     = @"AppleTalk is not supported on Basilisk II.\nThis is the worst known 1MB ROM.";
            romCondition = NoAppleTalk;
            break;
        case 0x3DC27823:
            fileDetails  = @"Macintosh Quadra 950";
            comments     = @"AppleTalk is not supported on Basilisk II.";
            romCondition = NoAppleTalk;
            break;
        case 0x49579803: // Very strange didn't find it, called IIvx
                         // 0x49579803 (different size)
            fileDetails  = @"Macintosh IIvx ?"; //Again? Brazil?
            romCondition = PerfectBasilisk;
            break;
        case 0xE33B2724:
            fileDetails  = @"Powerbook 160/165/165c/180/180c";
            romCondition = PerfectBasilisk;
            break;
        case 0xECFA989B:
            fileDetails = @"Powerbook 210/230/250";
            romCondition = PerfectBasilisk;
            break;
        case 0xEC904829:
            fileDetails  = @"Macintosh LC III";
            romCondition = PerfectBasilisk;
            break;
        case 0xECBBC41C:
            fileDetails  = @"Macintosh LCIII/LCIII+ or Performa 460";
            romCondition = PerfectBasilisk;
            break;
        case 0xECD99DC0:
            fileDetails  = @"Macintosh Color Classic / Performa 250";
            romCondition = PerfectBasilisk;
            break;
        case 0xF1A6F343:
            fileDetails  = @"Quadra/Centris 610 or 650";
            romCondition = PerfectBasilisk;
            break;
        case 0xF1ACAD13:	// Mac Quadra 650
            fileDetails  = @"Quadra/Centris 610 or 650 or 800";
            romCondition = PerfectBasilisk;
            break;
        case 0x0024D346:
            fileDetails  = @"Powerbook Duo 270C";
            romCondition = PerfectBasilisk;
            break;
        case 0xEDE66CBD:
            fileDetails  = @"Color Classic II, LC 550, Performa 275/550/560, Mac TV";//Maybe Performa 450-550";
            romCondition = PerfectBasilisk;
            break;
        case 0xFF7439EE:
            fileDetails  = @"LC 475/575 Quadra 605 Performa 475/476/575/577/578";
            comments     = @"Codename Aladdin";
            romCondition = PerfectBasilisk; //FPURequired; //?
            break;
        case 0x015621D7:
            fileDetails  = @"Powerbook Duo 280 or 280C";
            romCondition = PerfectBasilisk;
            break;
        case 0x06684214:
            fileDetails  = @"LC/Quadra/Performa 630";
            comments     = @"Codename Crusader";
            romCondition = PerfectBasilisk;
            break;
        case 0xFDA22562:
            fileDetails  = @"Powerbook 150";
            romCondition = PerfectBasilisk;
            break;
        case 0x064DC91D:
            fileDetails  = @"LC/Performa 580/588";
            comments     = @"AppleTalk is reported to work in Basilisk II.";
            romCondition = PerfectBasilisk;
            break;
        //------------------------------------------------
        // 2MB and 3MB ROMs
        // 2048 KB
        case 0xB6909089: // or 0x68LC040 ?
            fileDetails  = @"PowerBook 520/520c/540/540c";
            comments     = @"2MB ROM image. =D";
            romCondition = PerfectSheepOld;
            break;
        case 0x5BF10FD1:
            fileDetails  = @"Macintosh Quadra 660av or 840av";
            romCondition = PerfectSheepOld;
            break;
        case 0x4D27039C:
            fileDetails  = @"PowerBook 190 or 190cs";
            comments     = @"2MB ROM image. =D";
            romCondition = FPURequired;
            break;
        //------------------------------------------------
        // 4MB
        case 0x9FEB69B3:
            fileDetails  = @"Power Mac 6100/7100/8100";
            romCondition = PerfectSheepOld;
            break;
        case 0x9C7C98F7:
            fileDetails  = @"Workgroup Server 9150 80MHz";
            romCondition = PerfectSheepOld;
            break;
        case 0x9B7A3AAD:
            fileDetails  = @"Power Mac 7100 (newer)";
            romCondition = PerfectSheepOld;
            break;
        case 0x63ABFD3F:
            fileDetails  = @"Power Mac & Performa 5200/5300/6200/6300";
            romCondition = PerfectSheepOld;
            break;
        case 0x9B037F6F:
            fileDetails  = @"Workgroup Server 9150 120MHz";
            romCondition = PerfectSheepOld;
            break;
        case 0x83C54F75:
            fileDetails  = @"PowerBook 2300 & PB5x0 PPC Upgrade";
            romCondition = PerfectSheepOld;
            break;
        case 0x9630C68B:
            fileDetails  = @"Power Mac 7200/7500/8500/9500 v2";
            romCondition = PerfectSheepOld;
            break;
        case 0x96CD923D:
            fileDetails  = @"Power Mac 7200/7500/8500/9500 v1";
            comments     = @"Runs on Sheepshaver";
            romCondition = PerfectSheepOld;
            break;
        case 0x6F5724C0:
            fileDetails  = @"PowerM ac/Performa 6400";
            romCondition = PerfectSheepOld;
            break;
        case 0x83A21950:
            fileDetails = @"PowerBook 1400, 1400cs";
            romCondition = PerfectSheepOld;
            break;
        case 0x6E92FE08:
            fileDetails  = @"Power Mac 6500";
            romCondition = PerfectSheepOld;
            break;
        case 0x960E4BE9:
            fileDetails  = @"Power Mac 7300/7600/8600/9600 (v1)";
            romCondition = PerfectSheepOld;
            break;
        case 0x960FC647:
            fileDetails  = @"Power Mac 8600 or 9600 (v2)";
            romCondition = PerfectSheepOld;
            break;
        case 0x78F57389:
            fileDetails  = @"Power Mac G3 (v3)";
            romCondition = PerfectSheepOld;
            break;
        case 0x79D68D63:
            fileDetails  = @"Power Mac G3 desktop";
            romCondition = PerfectSheepOld;
            break;
        case 0xCBB01212:
            fileDetails  = @"PowerBook G3 Wallstreet";
            romCondition = PerfectSheepOld;
            break;
        case 0xB46FFB63:
            fileDetails  = @"PowerBook G3 Wallstreet PDQ";
            romCondition = PerfectSheepOld;
            break;
        //------------------------------------------------
        // 4MB New World ROM
        case 0x3C434852:
            fileDetails = @"The famous New World ROM from Apple's update";
            comments = @"Runs on Sheepshaver";
            romCondition = PerfectSheepNew;
            break;
        //------------------------------------------------
        // Unknown
        default:
            fileDetails = @"Unknown ROM";
            switch([size intValue]) {
                case 65536: //64KB
                case 131072: //128KB
                case 262144: //256KB
                    break;
                case 524288: //512KB
                    romCondition = NoAppleTalk;
                    break;
                case 1048576: //1MB
                case 2097152: //2MB
                case 3145728: //3MB
                case 4194304: //4MB
                default:
                    fileDetails  = @"Unsupported ROM size.";
                    comments     = [NSString stringWithFormat: @"%d", [size intValue]];
                    romCondition = Unsupported;
                    break;
            }
            break;

    }
    
    if (comments == nil) {
        comments = @"";
    }
    
    DDLogVerbose(@"fileDetails .. %@", fileDetails);
    DDLogVerbose(@"comments ..... %@", comments);
    DDLogVerbose(@"romCondition . %d", romCondition);
    
    [size release];    
    [romPath release];
}


@end
