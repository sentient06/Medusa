//
//  RomFilesEntityModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
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

enum RomCategory {
    OldWorldROM = 1
  , NewWorldROM
  , NoCategory
};

enum RomConditions {
    NormalCondition = 1
  , NoAppleTalk
  , FPURequired
  , NoAppleTalkAndFPURequired
  , UnsupportedRom
  , IgnoreIllegalMemoryInstructionsDisableJIT
};

enum RomSizes {
    romNull = 0,
    rom64KB,
    rom128KB,
    rom256KB,
    rom512KB,
    rom1MB,
    rom2MB,
    rom3MB,
    rom4MB,
};

enum RomIcons {
    DeadMac
  , BlackAndWhiteHappyMac
  , ColouredHappyMac
  , MiniVMacMac
  , QuestionMarkMac
};

@class VirtualMachinesEntityModel;

@interface RomFilesEntityModel : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * emulatorType;
@property (nonatomic, retain) NSNumber * fileMissing;
@property (nonatomic, retain) NSData   * fileAlias;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSString * checksum;
@property (nonatomic, retain) NSNumber * romCondition;
@property (nonatomic, retain) NSNumber * romCategory;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, retain) NSSet    * machines;

@end

@interface RomFilesEntityModel (CoreDataGeneratedAccessors)

- (void)addMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)removeMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;
- (NSNumber *)icon;
- (NSString *)filePath;

@end
