//
//  RomEmulatorTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 12/06/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
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

#import "RomEmulatorTransformer.h"
#import "EmulatorsEntityModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_OFF;
//------------------------------------------------------------------------------

@implementation RomEmulatorTransformer


+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    int emulatorCode = [value intValue];
    DDLogVerbose(@"Rom emulator is #%d", emulatorCode);
    switch (emulatorCode) {
        case vMacStandard:
            return @"Mini vMac";
        case vMacModelCompilation:
            return @"Mini vMac specific-model compiled";
        case vMacOther1:
            return @"Mini vMac (other)";
        case vMacOther2:
            return @"Mini vMac (other)";
        case BasiliskII:
            return @"Basilisk II";
        case BasiliskIIOther1:
            return @"Basilisk II (other)";
        case BasiliskIIOther2:
            return @"Basilisk II (other)";
        case vMacStandardAndBasiliskII:
            return @"Mini vMac and Basilisk II";
        case vMacModelCompilationAndBasiliskII:
            return @"Mini vMac (model-compiled) and Basilisk II";
        case EmulatorCombo1:
            return @"Unknown";
        case EmulatorCombo2:
            return @"Unknown";
        case Sheepshaver:
            return @"Sheepshaver";
        case SheepshaverOther1:
            return @"Sheepshaver (other)";
        case SheepshaverOther2:
            return @"Sheepshaver (other)";
        case EmulatorUnsupported:
        default:
            return @"No emulation possible";
    }
}

@end
