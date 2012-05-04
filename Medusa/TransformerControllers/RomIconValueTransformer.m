//
//  RomIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 01/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "RomIconValueTransformer.h"

@implementation RomIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
	
	//NSString *icon = [value stringValue];
    //NSLog(@"%ld", _icon);
    
    if ([value isEqualToString:@"Basilisk"]) {
        return [NSImage imageNamed:@"FinderGrey.icns"];
    }
    
    if ([value isEqualToString:@"Sheepshaver"]) {
        return [NSImage imageNamed:@"FinderBlue.icns"];
    }
	
	return [NSImage imageNamed:@"GenericQuestionMarkIcon.icns"];
}

@end