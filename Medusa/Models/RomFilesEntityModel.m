//
//  RomFilesEntityModel.m
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

#import "RomFilesEntityModel.h"
#import "VirtualMachinesEntityModel.h"
#import "EmulatorsEntityModel.h"
#import "FileManager.h"

@implementation RomFilesEntityModel

@dynamic comments;
@dynamic emulatorType;
@dynamic fileMissing;
@dynamic fileAlias;
@dynamic modelName;
@dynamic checksum;
@dynamic romCondition;
@dynamic romCategory;
@dynamic machines;

//@dynamic mac68kOld;
//@dynamic mac68kNew;
//@dynamic macPPCOld;
//@dynamic macPPCNew;

@dynamic fileSize;

- (NSNumber *)icon {
    int myCategory  = [[self romCategory ] intValue];
    int myEmulator  = [[self emulatorType] intValue];
    int myCondition = [[self romCondition] intValue];
    if (myCondition == UnsupportedRom || myEmulator == EmulatorUnsupported) {
        return [NSNumber numberWithInt:DeadMac];
    } else {
        if (myEmulator >= vMacStandard && myEmulator <= vMacOther2) {
            return [NSNumber numberWithInt:MiniVMacMac];
        } else {
            if (myCategory == OldWorldROM) {
                return [NSNumber numberWithInt:BlackAndWhiteHappyMac];
            } else if (myCategory >= NewWorldROM) {
                return [NSNumber numberWithInt:ColouredHappyMac];
            } else {
                return [NSNumber numberWithInt:QuestionMarkMac];
            }
        }
    }

}

- (NSString *)filePath {
    return [FileManager resolveAlias:[self fileAlias]];
}

@end
