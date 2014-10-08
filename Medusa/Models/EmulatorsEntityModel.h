//
//  EmulatorsEntityModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 27/09/2013.
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

#import <CoreData/CoreData.h>

enum emulatorfamily {
    undefinedFamily = 0,
    miniVMacFamily,
    basiliskFamily,
    sheepshaverFamily,
    qemuFamily,
    m68kFamily,
    ppcFamily,
    noFamily
};

// I decided to insert a shitload of emulators here to avoid annoying data
// migration codes. I don't expect to use more than a handful of these anyway,
// given that ROM files are not necessary for more recent emulators.
enum EmulatorTypes {
    EmulatorUnsupported = 0
  , vMacStandard
  , vMacModelCompilation
  , vMacOther1
  , vMacOther2
  , BasiliskII
  , BasiliskIIOther1
  , BasiliskIIOther2
  , vMacStandardAndBasiliskII
  , vMacModelCompilationAndBasiliskII
  , EmulatorCombo1
  , EmulatorCombo2
  , Sheepshaver
  , SheepshaverOther1
  , SheepshaverOther2
};

//enum GestaltCodes {
//    gestaltClassic           =   1, //  Macintosh
//    gestaltMacXL             =   2, //  Macintosh XL
//    gestaltMac512ke          =   3, //  Macintosh 512Ke
//    gestaltMacPlus           =   4, //  Macintosh Plus
//    gestaltMacSE             =   5, //  Macintosh SE
//    gestaltMacII             =   6, //  Macintosh II
//    gestaltMacIIx            =   7, //  Macintosh IIx
//    gestaltMacIIcx           =   8, //  Macintosh IIcx
//    gestaltMacSE30           =   9, //  Macintosh SE/30
//    gestaltMacPortable       =  10, //  Macintosh Portable
//    gestaltMacIIci           =  11, //  Macintosh IIci
//    gestaltMacIIfx           =  13, //  Macintosh IIfx
//    gestaltMacClassic        =  17, //  Macintosh Classic
//    gestaltMacIIsi           =  18, //  Macintosh IIsi
//    gestaltMacLC             =  19, //  Macintosh LC
//    gestaltQuadra900         =  20, //  Macintosh Quadra 900
//    gestaltPowerBook170      =  21, //  Macintosh PowerBook 170
//    gestaltQuadra700         =  22, //  Macintosh Quadra 700
//    gestaltClassicII         =  23, //  Macintosh Classic II
//    gestaltPowerBook100      =  24, //  Macintosh PowerBook 100
//    gestaltPowerBook140      =  25, //  Macintosh PowerBook 140
//    gestaltQuadra950         =  26, //  Macintosh Quadra 95
//    gestaltMacLCIII          =  27, //  Macintosh LC III
//    gestaltPowerBookDuo210   =  29, //  Macintosh PowerBook Duo 210
//    gestaltMacCentris650     =  30, //  Macintosh Centris 650
//    gestaltPowerBookDuo230   =  32, //  Macintosh PowerBook Duo 230
//    gestaltPowerBook180      =  33, //  Macintosh PowerBook 180
//    gestaltPowerBook160      =  34, //  Macintosh PowerBook 160
//    gestaltMacQuadra800      =  35, //  Macintosh Quadra 800
//    gestaltMacQuadra650      =  36, //  Macintosh Quadra 650
//    gestaltMacLCII           =  37, //  Macintosh LC II
//    gestaltPowerBookDuo250   =  38, //  Macintosh PowerBook Duo 250
//    gestaltAWS9150_80        =  39, //  Workgroup Server 9150
//    gestaltPowerMac8100_110  =  40, //  Power Macintosh 8100/110
//    gestaltPowerMac5200_75   =  41, //  Power Macintosh 5200/75
//    gestaltPowerMac6200_75   =  42, //  Power Macintosh 6200/75
//    gestaltMacIIvi           =  44, //  Macintosh IIvi
//    gestaltPerforma600       =  45, //  Macintosh Performa 600
//    gestaltPowerMac7100_80   =  47, //  Power Macintosh 7100/80
//    gestaltMacIIvx           =  48, //  Macintosh IIvx
//    gestaltMacColorClassic   =  49, //  Macintosh Color Classic
//    gestaltPowerBook165c     =  50, //  Macintosh PowerBook 165c
//    gestaltMacCentris610     =  52, //  Macintosh Centris 610
//    gestaltMacQuadra610      =  53, //  Macintosh Quadra 610
//    gestaltPowerBook145      =  54, //  Macintosh PowerBook 145 & 145
//    gestaltPowerMac8100_100  =  55, //  Power Macintosh 8100/100
//    gestaltMacLC520          =  56, //  Macintosh LC 520
//    gestaltAWS9150_120       =  57, //  Workgroup Server 9150/120
//    gestaltPerforma6400      =  58, //  Macintosh Performa 6400/180, 6400/200
//    gestaltPerforma6360      =  58, //  Macintosh Performa 6360/160
//    gestaltMacCentris660AV   =  60, //  Macintosh Centris 660AV
//    gestaltPerforma460       =  62, //  Macintosh Performa 460
//    gestaltPowerMac8100_80   =  65, //  Power Macintosh 8100/80
//    gestaltPowerMac9500_120  =  67, //  Power Macintosh 9500/120
//    gestaltPowerMac9600      =  67, //  Power Macintosh 9600
//    gestaltPowerMac7500_120  =  68, //  Power Macintosh 7200/120
//    gestaltPowerMac8500_120  =  68, //  Power Macintosh 8500/120
//    gestaltPowerMac8600      =  69, //  Power Macintosh 8600
//    gestaltPowerBook180c     =  71, //  Macintosh PowerBook 180c
//    gestaltPowerBook500      =  72, //  Macintosh PowerBook 500 series
//    gestaltPowerMac5400      =  74, //  Power Macintosh 5400
//    gestaltPowerMac6100_60   =  75, //  Power Macintosh 6100/60
//    gestaltPowerBookDuo270c  =  77, //  Macintosh PowerBook Duo 270c
//    gestaltMacQuadra840AV    =  78, //  Macintosh Quadra 840AV
//    gestaltMacLC550          =  80, //  Macintosh LC 550
//    gestaltPowerBook165      =  84, //  Macintosh PowerBook 165
//    gestaltMacTV             =  88, //  Macintosh TV
//    gestaltMacLC475          =  89, //  Macintosh LC 475
//    gestaltMacLC575          =  92, //  Macintosh LC 575
//    gestaltMacQuadra605      =  94, //  Macintosh Quadra 605
//    gestaltMac630            =  98, //  Macintosh 630 series
//    gestaltMacLC580          =  99, //  Macintosh LC 580
//    gestaltPowerMac6100_66   = 100, //  Power Macintosh 6100/66
//    gestaltPowerBookDuo280   = 102, //  Macintosh PowerBook Duo 280
//    gestaltPowerBookDuo280c  = 103, //  Macintosh PowerBook Duo 280c
//    gestaltPowerMac7200_90   = 108, //  Power Macintosh 7200/90
//    gestaltPowerMac7300      = 109, //  Power Macintosh 7300
//    gestaltPowerMac7100_66   = 112, //  Power Macintosh 7100/66
//    gestaltPowerBook150      = 115, //  Macintosh PowerBook 150
//    gestaltPowerBookDuo2300  = 118, //  Macintosh PowerBook Duo 2300
//    gestaltPowerBook190      = 122, //  Macintosh PowerBook 190
//    gestaltPowerBook5300     = 128, //  Macintosh PowerBook 5300
//    gestaltPowerBook1400     = 310, //  Macintosh PowerBook 1400
//    gestaltPowerMacG3        = 510  //  Power Macintosh G3
//};

@class VirtualMachinesEntityModel;

@interface EmulatorsEntityModel : NSManagedObject

@property (nonatomic, retain) NSNumber * family;
@property (nonatomic, retain) NSNumber * maintained;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * readablePath;
@property (nonatomic, retain) NSString * unixPath;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSSet    * machines;

@end

@interface EmulatorsEntityModel (CoreDataGeneratedAccessors)

- (void)addMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)removeMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;

@end
