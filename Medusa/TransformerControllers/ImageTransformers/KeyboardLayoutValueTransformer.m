//
//  KeyboardLayoutValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 08/10/2013.
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

#import "KeyboardLayoutValueTransformer.h"

@implementation KeyboardLayoutValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
	switch ([value intValue]) {
        case 1:
            return [NSImage imageNamed:@"001 - Apple Keyboard.gif"];
        case 2:
            return [NSImage imageNamed:@"002 - Apple Extended Keyboard.gif"];
        case 3:
            return [NSImage imageNamed:@"003 - Macintosh 512K Keyboard.gif"];
        case 4:
            return [NSImage imageNamed:@"004 - Apple ISO Keyboard.gif"];
        case 5:
            return [NSImage imageNamed:@"005 - Apple ISO Extended Keyboard.gif"];
        case 6:
            return [NSImage imageNamed:@"006 - Macintosh Portable Keyboard.gif"];
        case 7:
            return [NSImage imageNamed:@"007 - Macintosh Portable International Keyboard.gif"];
        case 8:
            return [NSImage imageNamed:@"008 - Macintosh Keyboard II.gif"];
        case 9:
            return [NSImage imageNamed:@"009 - Macintosh International Keyboard II.gif"];
        case 10:
            return [NSImage imageNamed:@"010 - Unknown Keyboard.gif"];
        case 11:
            return [NSImage imageNamed:@"011 - Macintosh Plus Keyboard.gif"];
        case 12:
            return [NSImage imageNamed:@"012 - PowerBook Keyboard.gif"];
        case 13:
            return [NSImage imageNamed:@"013 - PowerBook ISO Keyboard.gif"];
        case 14:
            return [NSImage imageNamed:@"014 - Apple Adjustable Numeric Keyboard.gif"];
        case 16:
            return [NSImage imageNamed:@"016 - Apple Adjustable Keyboard.gif"];
        case 17:
            return [NSImage imageNamed:@"017 - Apple Adjustable ISO Keyboard.gif"];
        case 20:
            return [NSImage imageNamed:@"020 - PowerBook Extended Keyboard.gif"];
        case 24:
            return [NSImage imageNamed:@"024 - PowerBook ISO Extended Keyboard.gif"];
        case 259:
            return [NSImage imageNamed:@"259 - Macintosh 512K International Keyboard.gif"];
    }

    return nil;

}

@end
