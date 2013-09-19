//
//  RomModel.h
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

#import <Foundation/Foundation.h>

enum RomConditions {
    PerfectSheepNew        = 1,
    PerfectSheepOld        = 2,
    PerfectBasilisk        = 3,
    NoAppleTalk            = 4,
    FPURequired            = 5,
    NoAppleTalkFPURequired = 6,
    PerfectVMac            = 7,
    Unsupported            = 8
};

enum RomSizes {
    romNull  = 0,
    rom64KB  = 1,
    rom128KB = 2,
    rom256KB = 3,
    rom512KB = 4,
    rom1MB   = 5,
    rom2MB   = 6,
    rom3MB   = 7,
    rom4MB   = 8
};

@class RomFilesModel;

@interface RomModel : NSObject {
//@private
    NSString * fileDetails;
    NSString * comments;
    int romCondition;
    int romSize;
}

@property (readonly, strong, nonatomic) RomFilesModel * currentRomObject;

- (id)parseSingleRomFileAndSave:(NSString *)filePath inObjectContext:(NSManagedObjectContext *)currentContext;
- (void)parseRomFilesAndSave:(NSArray *)filesList;
- (void)readRomFileFrom:(NSString *)filePath; //Got from FileHandler

@end
