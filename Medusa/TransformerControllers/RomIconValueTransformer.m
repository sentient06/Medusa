//
//  RomIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 01/05/2012.
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

#import "RomIconValueTransformer.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation RomIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
	
	//NSString *icon = [value stringValue];
    //DDLogVerbose(@"%ld", _icon);
    
//    if ([value isEqualToString:@"Basilisk"]) {
//        return [NSImage imageNamed:@"FinderGrey.icns"];
//    }
//    
//    if ([value isEqualToString:@"Sheepshaver"]) {
//        return [NSImage imageNamed:@"FinderBlue.icns"];
//    }
    
    
//    enum RomConditions {
//        PerfectSheepNew        = 1,
//        PerfectSheepOld        = 2,
//        PerfectBasilisk        = 3,
//        NoAppleTalk            = 4,
//        FPURequired            = 5,
//        NoAppleTalkFPURequired = 6,
//        PerfectVMac            = 7,
//        Unsupported            = 8
//    };
    
    
    
    long iconValue = [value integerValue];
    
    DDLogVerbose(@"Rom Icon Value Transformer - value: %@ -- %ld", value, iconValue);
    
    if (iconValue == 1) {
        return [NSImage imageNamed:@"PerfectNew.png"];
    }
    
    if (iconValue > 1 && iconValue < 8) {
        return [NSImage imageNamed:@"PerfectOld.png"];
    }
    
//    if (iconValue == 7) {
//        return [NSImage imageNamed:@"Unsupported.icns"];
//    }
    
	return [NSImage imageNamed:@"UnsupportedRom.png"];
}

@end