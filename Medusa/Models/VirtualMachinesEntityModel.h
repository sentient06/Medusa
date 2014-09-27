//
//  VirtualMachinesEntityModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 12/06/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum GestaltMacModels {
    Classic                 =  1,
    // Unsupported -------------
    MacXL                   =  2,
    Mac512KE                =  3,
    MacPlus                 =  4,
    MacSE                   =  5,
    MacII                   =  6,
    MacIIx                  =  7,
    MacIIcx                 =  8,
    MacSE030                =  9,
    // -------------------------
    MacPortable             = 10,
    MacIIci                 = 11,
    MacIIfx                 = 13,
    MacClassic              = 17,
    MacIIsi                 = 18,
    MacLC                   = 19,
    Quadra900               = 20,
    PowerBook170            = 21,
    Quadra700               = 22,
    ClassicII               = 23,
    PowerBook100            = 24,
    PowerBook140            = 25,
    Quadra950               = 26,
    MacLCIIIPerforma450     = 27,
    PowerBookDuo210         = 29,
    Centris650              = 30,
    PowerBookDuo230         = 32,
    PowerBook180            = 33,
    PowerBook160            = 34,
    Quadra800               = 35,
    Quadra650               = 36,
    MacLCII                 = 37,
    PowerBookDuo250         = 38,
    MacIIvi                 = 44,
    MacIIvmPerforma600      = 45,
    MacIIvx                 = 48,
    ColorClassicPerforma250 = 49,
    PowerBook165c           = 50,
    Centris610              = 52,
    Quadra610               = 53,
    PowerBook145            = 54,
    MacLC520                = 56,
    QuadraCentris660AV      = 60,
    Performa46x             = 62,
    PowerBook180c           = 71,
    PowerBook520520c540540c = 72,
    PowerBookDuo270c        = 77,
    Quadra840AV             = 78,
    Performa550             = 80,
    PowerBook165            = 84,
    PowerBook190            = 85,
    MacTV                   = 88,
    MacLC475Performa47x     = 89,
    MacLC575                = 92,
    Quadra605               = 94,
    Quadra630               = 98,
    MacLC580                = 99,
    PowerBookDuo280         = 102,
    PowerBookDuo280c        = 103,
    PowerBook150            = 115
};

enum VirtualMachineIcons {
      NewVM
    , DeadVM
    , BlackAndWhiteNoDisk
    , ColouredNoDisk
    , NoEmulatorVM
    , BlackAndWhiteHappyVM
    , ColouredHappyVM
    , QuestionMarkVM
    , BlackAndWhiteHappyVMLocked
    , ColouredHappyVMLocked
};

@class RelationshipVirtualMachinesDiskFilesEntityModel, RomFilesEntityModel, EmulatorsEntityModel;

@interface VirtualMachinesEntityModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uniqueName;
@property (nonatomic, retain) NSNumber * macModel;
@property (nonatomic, retain) NSNumber * memory;
@property (nonatomic, retain) NSNumber * processorType;

@property (nonatomic, retain) NSNumber * displayColourDepth;
@property (nonatomic, retain) NSNumber * displayDynamicUpdate;
@property (nonatomic, retain) NSNumber * displayFrameSkip;
@property (nonatomic, retain) NSNumber * displayHeight;
@property (nonatomic, retain) NSNumber * displayWidth;
@property (nonatomic, retain) NSNumber * fullScreen;

@property (nonatomic, retain) NSNumber * fpuEnabled;
@property (nonatomic, retain) NSNumber * jitCacheSize;
@property (nonatomic, retain) NSNumber * jitEnabled;
@property (nonatomic, retain) NSNumber * lazyCacheEnabled;

@property (nonatomic, retain) NSNumber * network;
@property (nonatomic, retain) NSNumber * networkUDP;
@property (nonatomic, retain) NSNumber * networkUDPPort;
@property (nonatomic, retain) NSNumber * networkTap0;
@property (nonatomic, retain) NSNumber * shareEnabled;
@property (nonatomic, retain) NSString * sharedFolder;
@property (nonatomic, retain) NSNumber * useDefaultShare;
@property (nonatomic, retain) NSNumber * keyboardLayout;

@property (nonatomic, retain) NSString * rawKeycodes;

@property (nonatomic, retain) NSNumber * running;
@property (nonatomic, retain) NSNumber * taskPID;

@property (nonatomic, retain) NSSet    * disks;
@property (nonatomic, retain) RomFilesEntityModel  * romFile;
@property (nonatomic, retain) EmulatorsEntityModel * emulator;

@end

@interface VirtualMachinesEntityModel (CoreDataGeneratedAccessors)

- (void)addDisksObject:(RelationshipVirtualMachinesDiskFilesEntityModel *)value;
- (void)removeDisksObject:(RelationshipVirtualMachinesDiskFilesEntityModel *)value;
- (void)addDisks:(NSSet *)values;
- (void)removeDisks:(NSSet *)values;
- (NSNumber *)nextDiskIndex;

- (NSNumber *)icon;
- (BOOL)canRun;

- (BOOL)sheepShaverSetup;
- (BOOL)basilisk2Setup;

@end