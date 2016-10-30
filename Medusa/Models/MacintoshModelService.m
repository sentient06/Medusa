//
//  MacintoshModelModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 15/11/2013.
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

#import "MacintoshModelService.h"
#import "EmulatorModel.h"
#import "EmulatorsEntityModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_OFF;
//------------------------------------------------------------------------------

@implementation MacintoshModelService
@synthesize modelName, modelId;

- (void)dealloc {
    [modelId release];
    [modelName release];
    [super dealloc];
}

+ (NSDictionary *)fetchAllAvailableModelsForEmulatorType:(int)emulatorType {
    switch (emulatorType) {
        case vMacStandard:
        case vMacModelCompilation:
        case vMacOther1:
        case vMacOther2: //Macintosh 128K, 512K, 512Ke, SE, Classic, and SE FDHD, Plus
            return [NSDictionary dictionaryWithObjectsAndKeys:
                @"1. Mac 128K",                     [NSNumber numberWithInt:1]//128k
              , @"2. Mac 512K / XL",                [NSNumber numberWithInt:2]// and 512K
              , @"3. Mac 512KE",                    [NSNumber numberWithInt:3]//v
              , @"4. Mac Plus",                     [NSNumber numberWithInt:4]//v
              , @"5. Mac SE",                       [NSNumber numberWithInt:5]//v and fdhd
              , @"5. Mac SE FDHD",                  [NSNumber numberWithInt:5]//FFFFFFUUUUUUUUUUUUU-
              , @"17. Mac Classic",                 [NSNumber numberWithInt:17] //v
              , nil];
  
            break;
            
        case BasiliskII:
        case BasiliskIIOther1:
        case BasiliskIIOther2:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                @"4. Mac Plus",                     [NSNumber numberWithInt:4]
              , @"6. Mac II",                       [NSNumber numberWithInt:6]
              , @"7. Mac IIx",                      [NSNumber numberWithInt:7]
              , @"8. Mac IIcx",                     [NSNumber numberWithInt:8]
              , @"9. Mac SE/030",                   [NSNumber numberWithInt:9]
              , @"10. Mac Portable",                [NSNumber numberWithInt:10]
              , @"11. Mac IIci",                    [NSNumber numberWithInt:11]
              , @"13. Mac IIfx",                    [NSNumber numberWithInt:13]
              , @"17. Mac Classic",                 [NSNumber numberWithInt:17]
              , @"18. Mac IIsi",                    [NSNumber numberWithInt:18]
              , @"19. Mac LC",                      [NSNumber numberWithInt:19]
              , @"20. Quadra 900",                  [NSNumber numberWithInt:20]
              , @"21. PowerBook 170",               [NSNumber numberWithInt:21]
              , @"22. Quadra 700",                  [NSNumber numberWithInt:22]
              , @"23. Classic II",                  [NSNumber numberWithInt:23]
              , @"24. PowerBook 100",               [NSNumber numberWithInt:24]
              , @"25. PowerBook 140",               [NSNumber numberWithInt:25]
              , @"26. Quadra 950",                  [NSNumber numberWithInt:26]
              , @"27. Mac LCIII/Performa 450",      [NSNumber numberWithInt:27]
              , @"29. PowerBook Duo 210",           [NSNumber numberWithInt:29]
              , @"30. Centris 650",                 [NSNumber numberWithInt:30]
              , @"32. PowerBook Duo 230",           [NSNumber numberWithInt:32]
              , @"33. PowerBook 180",               [NSNumber numberWithInt:33]
              , @"34. PowerBook 160",               [NSNumber numberWithInt:34]
              , @"35. Quadra 800",                  [NSNumber numberWithInt:35]
              , @"36. Quadra 650",                  [NSNumber numberWithInt:36]
              , @"37. Mac LCII",                    [NSNumber numberWithInt:37]
              , @"38. PowerBook Duo 250",           [NSNumber numberWithInt:38]
              , @"44. Mac IIvi",                    [NSNumber numberWithInt:44]
              , @"45. Mac IIvm/Performa 600",       [NSNumber numberWithInt:45]
              , @"48. Mac IIvx",                    [NSNumber numberWithInt:48]
              , @"49. Color Classic/Performa 250",  [NSNumber numberWithInt:49]
              , @"50. PowerBook 165c",              [NSNumber numberWithInt:50]
              , @"52. Centris 610",                 [NSNumber numberWithInt:52]
              , @"53. Quadra 610",                  [NSNumber numberWithInt:53]
              , @"54. PowerBook 145",               [NSNumber numberWithInt:54]
              , @"56. Mac LC520",                   [NSNumber numberWithInt:56]
              , @"60. Quadra/Centris 660AV",        [NSNumber numberWithInt:60]
              , @"62. Performa 46x",                [NSNumber numberWithInt:62]
              , @"71. PowerBook 180c",              [NSNumber numberWithInt:71]
              , @"72. PowerBook 520/520c/540/540c", [NSNumber numberWithInt:72]
              , @"77. PowerBook Duo 270c",          [NSNumber numberWithInt:77]
              , @"78. Quadra 840AV",                [NSNumber numberWithInt:78]
              , @"80. Performa 550",                [NSNumber numberWithInt:80]
              , @"84. PowerBook 165",               [NSNumber numberWithInt:84]
              , @"85. PowerBook 190",               [NSNumber numberWithInt:85]
              , @"88. Mac TV",                      [NSNumber numberWithInt:88]
              , @"89. Mac LC475/Performa 47x",      [NSNumber numberWithInt:89]
              , @"92. Mac LC575",                   [NSNumber numberWithInt:92]
              , @"94. Quadra 605",                  [NSNumber numberWithInt:94]
              , @"98. Quadra 630",                  [NSNumber numberWithInt:98]
              , @"99. Mac LC580",                   [NSNumber numberWithInt:99]
              , @"102. PowerBook Duo 280",          [NSNumber numberWithInt:102]
              , @"103. PowerBook Duo 280c",         [NSNumber numberWithInt:103]
              , @"115. PowerBook 150",              [NSNumber numberWithInt:115]
              , nil];
            break;

        case vMacStandardAndBasiliskII:
        case vMacModelCompilationAndBasiliskII:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    @"4. Mac Plus", [NSNumber numberWithInt:4], nil];
            break;

        case Sheepshaver:
        case SheepshaverOther1:
        case SheepshaverOther2:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    @"Power Macintosh 9500/9600", [NSNumber numberWithInt:67]
                    , nil];
            break;            
            
        case EmulatorCombo1:
        case EmulatorCombo2:
        default:
            return nil;
            break;
    }
}


+ (NSDictionary *)fetchAllAvailableModelsForChecksum:(NSString *)checksum andEmulator:(int)emulatorType {
    
    NSDictionary * allowedGestalt;
    
    BOOL useSimpleModel = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"useSimpleModel"
    ];
    
    int emulatorFamily = [EmulatorModel familyFromEmulatorType: emulatorType];
    
    if (useSimpleModel && emulatorFamily == basiliskFamily) {
        allowedGestalt = [
            NSDictionary dictionaryWithObjectsAndKeys: // 11 20 IIci 900
                [NSString stringWithFormat:@"%d. Mac IIci (System 7 - 7.5)", gestaltMacIIci]
              , [NSNumber numberWithInt:gestaltMacIIci]
              , [NSString stringWithFormat:@"%d. Mac Quadra 900 (Mac OS 7.5 - 8.1)", gestaltMacQuadra900]
              , [NSNumber numberWithInt:gestaltMacQuadra900]
              , nil
        ];
        return allowedGestalt;
    }
    
    uint intChecksum = 0;
    NSScanner * scanner = [NSScanner scannerWithString:checksum];
    [scanner scanHexInt:&intChecksum];
    DDLogVerbose(@"String checksum ... %@", checksum);
    DDLogVerbose(@"Integer checksum .. %X", intChecksum);

    switch (emulatorType) {
        case Sheepshaver:
        case SheepshaverOther1:
        case SheepshaverOther2:
            allowedGestalt = [
                NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d. Power Macintosh 9500", gestaltPowerMac9500]
                  , [NSNumber numberWithInt:gestaltPowerMac9500]
                  , nil];
            break;
        default:
            switch( intChecksum ) {
                    //------------------------------------------------
                    // 64 KB
                case 0x4D1EEAE1:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Plus", gestaltMacPlus]
                          , [NSNumber numberWithInt:gestaltMacPlus]
                          , nil
                    ];
                    break;

                case 0x4D1F8172:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Plus", gestaltMacPlus]
                          , [NSNumber numberWithInt:gestaltMacPlus]
                          , nil
                    ];
                    break;
                    //------------------------------------------------
                    // 256 KB
                case 0xA49F9914:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Classic", gestaltMacClassic]
                          , [NSNumber numberWithInt:gestaltMacClassic]
                          , nil
                    ];
                    break;
                case 0x96645F9C:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook 100", gestaltPowerBook100]
                          , [NSNumber numberWithInt:gestaltPowerBook100]
                          , nil
                    ];
                    break;
                    //------------------------------------------------
                    // 512 KB
                case 0x4147DD77:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac IIfx", gestaltMacIIfx]
                          , [NSNumber numberWithInt:gestaltMacIIfx]
                          , nil
                    ];
                    break;
                case 0x350EACF0:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LC", gestaltMacLC]
                          , [NSNumber numberWithInt:gestaltMacLC]
                          , nil
                    ];
                    break;
                case 0x3193670E: //messy checksum
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Classic II", gestaltClassicII]
                          , [NSNumber numberWithInt:gestaltClassicII]
                          , nil
                    ];
                    break;
                case 0x368CADFE:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac IIci", gestaltMacIIci]
                          , [NSNumber numberWithInt:gestaltMacIIci]
                          , nil
                    ];
                    break;
                case 0x36B7FB6C:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac IIsi", gestaltMacIIsi]
                          , [NSNumber numberWithInt:gestaltMacIIsi]
                          , nil
                    ];
                    break;
                case 0x35C28F5F:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LCII", gestaltMacLCII]
                          , [NSNumber numberWithInt:gestaltMacLCII]
                          , nil
                    ];
                    break;
                    //--------------------------------------------
                case 0x35C28C8F: // Very strange didn't find it
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac IIx", gestaltMacIIx]
                          , [NSNumber numberWithInt:gestaltMacIIx]
                          , nil
                    ];
                    break;
                case 0x4957EB49:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac IIx", gestaltMacIIx]
                          , [NSNumber numberWithInt:gestaltMacIIx]
                          , [NSString stringWithFormat:@"%d. Mac IIvi", gestaltMacIIvi]
                          , [NSNumber numberWithInt:gestaltMacIIvi]
                          , [NSString stringWithFormat:@"%d. Performa 600", gestaltPerforma600]
                          , [NSNumber numberWithInt:gestaltPerforma600]
                          , nil
                    ];
                    break;
                    //------------------------------------------------
                    // 1024 KB
                    // Things get messy here
                case 0x420DBFF3:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Quadra 700", gestaltMacQuadra700]
                          , [NSNumber numberWithInt:gestaltMacQuadra700]
                          , [NSString stringWithFormat:@"%d. Mac Quadra 900", gestaltMacQuadra900]
                          , [NSNumber numberWithInt:gestaltMacQuadra900]
                          , [NSString stringWithFormat:@"%d. PowerBook 140", gestaltPowerBook140]
                          , [NSNumber numberWithInt:gestaltPowerBook140]
                          , [NSString stringWithFormat:@"%d. PowerBook 170", gestaltPowerBook170]
                          , [NSNumber numberWithInt:gestaltPowerBook170]
                          , nil
                    ];
                    break;
                case 0x3DC27823:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Quadra 950", gestaltMacQuadra950]
                          , [NSNumber numberWithInt:gestaltMacQuadra950]
                          , nil
                    ];
                    break;
                case 0x49579803: // Very strange didn't find it, called IIvx
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                    // 0x49579803 (different size)
                            [NSString stringWithFormat:@"%d. Mac IIvx", gestaltMacIIvx]
                          , [NSNumber numberWithInt:gestaltMacIIvx]
                          , nil
                    ];
                    break;
                case 0xE33B2724:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook 160", gestaltPowerBook160]
                          , [NSNumber numberWithInt:gestaltPowerBook160]
                          , [NSString stringWithFormat:@"%d. PowerBook 165", gestaltPowerBook165]
                          , [NSNumber numberWithInt:gestaltPowerBook165]
                          , [NSString stringWithFormat:@"%d. PowerBook 165c", gestaltPowerBook165c]
                          , [NSNumber numberWithInt:gestaltPowerBook165c]
                          , [NSString stringWithFormat:@"%d. PowerBook 180", gestaltPowerBook180]
                          , [NSNumber numberWithInt:gestaltPowerBook180]
                          , [NSString stringWithFormat:@"%d. PowerBook 180c", gestaltPowerBook180c]
                          , [NSNumber numberWithInt:gestaltPowerBook180c]
                          , nil
                    ];
                    break;
                case 0xECFA989B:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook Duo 210", gestaltPowerBookDuo210]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo210]
                          , [NSString stringWithFormat:@"%d. PowerBook Duo 230", gestaltPowerBookDuo230]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo230]
                          , [NSString stringWithFormat:@"%d. PowerBook Duo 250", gestaltPowerBookDuo250]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo250]
                          , nil
                    ];
                    break;
                case 0xEC904829:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LC III", gestaltMacLCIII]
                          , [NSNumber numberWithInt:gestaltMacLCIII]
                          , nil
                    ];
                    break;
                case 0xECBBC41C:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LC III", gestaltMacLCIII]
                          , [NSNumber numberWithInt:gestaltMacLCIII]
                          , [NSString stringWithFormat:@"%d. Performa 46x", gestaltPerforma46x]
                          , [NSNumber numberWithInt:gestaltPerforma46x]
                          , nil
                    ];
                    break;
                case 0xECD99DC0:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Color Classic", gestaltMacColorClassic]
                          , [NSNumber numberWithInt:gestaltMacColorClassic]
                          , [NSString stringWithFormat:@"%d. Performa 250", gestaltPerforma250]
                          , [NSNumber numberWithInt:gestaltPerforma250]
                          , nil
                    ];
                    break;
                case 0xF1A6F343:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Quadra 610", gestaltQuadra610]
                          , [NSNumber numberWithInt:gestaltQuadra610]
                          , [NSString stringWithFormat:@"%d. Quadra 650", gestaltQuadra650]
                          , [NSNumber numberWithInt:gestaltQuadra650]
                          , nil
                    ];
                    break;
                case 0xF1ACAD13:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Quadra 610", gestaltQuadra610]
                          , [NSNumber numberWithInt:gestaltQuadra610]
                          , [NSString stringWithFormat:@"%d. Quadra 650", gestaltQuadra650]
                          , [NSNumber numberWithInt:gestaltQuadra650]
                          , [NSString stringWithFormat:@"%d. Quadra 800", gestaltQuadra800]
                          , [NSNumber numberWithInt:gestaltQuadra800]
                          , [NSString stringWithFormat:@"%d. Mac Centris 610", gestaltMacCentris610]
                          , [NSNumber numberWithInt:gestaltMacCentris610]
                          , [NSString stringWithFormat:@"%d. Mac Centris 650", gestaltMacCentris650]
                          , [NSNumber numberWithInt:gestaltMacCentris650]
                          , nil
                    ];
                    break;
                case 0x0024D346:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook Duo 270c", gestaltPowerBookDuo270c]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo270c]
                          , nil
                    ];
                    break;
                case 0xEDE66CBD:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Performa 550", gestaltPerforma550]
                          , [NSNumber numberWithInt:gestaltPerforma550]
                          , [NSString stringWithFormat:@"%d. Mac TV", gestaltMacTV]
                          , [NSNumber numberWithInt:gestaltMacTV]
                          , nil
                    ];
                    break;
                case 0xFF7439EE:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LC 475", gestaltMacLC475]
                          , [NSNumber numberWithInt:gestaltMacLC475]
                          , [NSString stringWithFormat:@"%d. Mac LC 575", gestaltMacLC575]
                          , [NSNumber numberWithInt:gestaltMacLC575]
                          , [NSString stringWithFormat:@"%d. Mac Quadra 605", gestaltMacQuadra605]
                          , [NSNumber numberWithInt:gestaltMacQuadra605]
                          , nil
                    ];
                    break;
                case 0x015621D7:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook Duo 280", gestaltPowerBookDuo280]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo280]
                          , [NSString stringWithFormat:@"%d. PowerBook Duo 280c", gestaltPowerBookDuo280c]
                          , [NSNumber numberWithInt:gestaltPowerBookDuo280c]
                          , nil
                    ];
                    break;
                case 0x06684214:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac Quadra 630", gestaltMacQuadra630]
                          , [NSNumber numberWithInt:gestaltMacQuadra630]
                          , nil
                    ];
                    break;
                case 0xFDA22562:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerBook 150", gestaltPowerBook150]
                          , [NSNumber numberWithInt:gestaltPowerBook150]
                          , nil
                    ];
                    break;
                case 0x064DC91D:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. Mac LC 580", gestaltMacLC580]
                          , [NSNumber numberWithInt:gestaltMacLC580]
                          , nil
                    ];
                    break;
                    //------------------------------------------------
                    // New World ROM or 4MBor 2MB or 3MB ROMs
                default:
                    allowedGestalt = [
                        NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d. PowerMac 9500", gestaltPowerMac9500]
                          , [NSNumber numberWithInt:gestaltPowerMac9500]
                          , nil
                    ];
            }
    }
    
    return allowedGestalt;
}

@end
