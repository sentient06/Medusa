//
//  VirtualMachinesModel.m
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

#import "VirtualMachinesModel.h"
#import "RelationshipVirtualMachinesDiskFilesModel.h"
#import "RomFilesModel.h"
#import "EmulatorsModel.h"
#import "EmulatorService.h"

@implementation VirtualMachinesModel

@dynamic name;
@dynamic uniqueName;
@dynamic macModel;
@dynamic memory;
@dynamic processorType;

@dynamic displayColourDepth;
@dynamic displayDynamicUpdate;
@dynamic displayFrameSkip;
@dynamic displayHeight;
@dynamic displayWidth;
@dynamic fullScreen;
@dynamic quickdrawAcceleration;

@dynamic fpuEnabled;
@dynamic jitCacheSize;
@dynamic jitEnabled;
@dynamic lazyCacheEnabled;
@dynamic enable68k;
@dynamic idleWait;
@dynamic noClipboardConversion;

@dynamic network;
@dynamic networkUDP;
@dynamic networkUDPPort;
@dynamic networkTap0;
@dynamic shareEnabled;
@dynamic sharedFolder;
@dynamic extraPreferences;
@dynamic useDefaultShare;
@dynamic keyboardLayout;
@dynamic rawKeycodes;

@dynamic running;
@dynamic taskPID;

@dynamic disks;
@dynamic romFile;
@dynamic emulator;

- (NSNumber *)icon {
    
    short value = QuestionMarkMac;
    
    // Rom:
    short category  = [[[self romFile] romCategory ] integerValue];
    short condition = [[[self romFile] romCondition] integerValue];

    // Disks:
    NSInteger totalDisks = [[self disks] count];

    if ([self romFile] == NULL) {
        if ([self emulator] == NULL) {
            if (totalDisks == 0) {
                value = NewVM;
            } else {
                value = QuestionMarkVM;
            }
        } else {
            value = QuestionMarkVM;
        }
    } else if (condition == UnsupportedRom) {
        value = DeadVM;
    } else {
        if (totalDisks == 0) {
            if ([self emulator] == NULL) {
                value = QuestionMarkVM;
            } else {
                if (category == OldWorldROM) {
                    value = BlackAndWhiteNoDisk;
                }
                if (category == NewWorldROM) {
                    value = ColouredNoDisk;
                }
            }
        } else {
            if ([self emulator] == NULL) {
                value = QuestionMarkVM;
            } else {
                if (category == OldWorldROM) {
                    if ([[self running] intValue] == 1) {
                        value = BlackAndWhiteHappyVMLocked;
                    } else {
                        value = BlackAndWhiteHappyVM;
                    }
                }
                if (category == NewWorldROM) {
                    if ([[self running] intValue] == 1) {
                        value = ColouredHappyVMLocked;
                    } else {
                        value = ColouredHappyVM;
                    }
                }
            }
        }
    }
    
    return [NSNumber numberWithInt:value];
}

- (BOOL)canRun {
    if ([self romFile]      == nil ||
        [self emulator]     == nil ||
       [[self disks] count] == 0)
        return NO;
    else
        return YES;
}

- (BOOL)hasRom {
    if ([self romFile] == nil)
        return NO;
    else
        return YES;
}

- (NSNumber *)nextDiskIndex {
    return [NSNumber numberWithUnsignedInteger:[[self disks] count]];
}

- (BOOL)sheepShaverSetup {
    int type = [EmulatorService familyFromEmulatorType:[[[self romFile] emulatorType] intValue]];
    return type == sheepshaverFamily;
}

- (BOOL)basilisk2Setup {
    int type = [EmulatorService familyFromEmulatorType:[[[self romFile] emulatorType] intValue]];
    return type == basiliskFamily;
}

- (BOOL)showGestaltList {
    BOOL useSimpleModel = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"useSimpleModel"
    ];
    if ([self basilisk2Setup]) {
        if (useSimpleModel) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (BOOL)busy {
    return [[self running] boolValue];
}

@end
