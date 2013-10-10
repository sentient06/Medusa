//
//  KeyboardLayoutValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 08/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

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
