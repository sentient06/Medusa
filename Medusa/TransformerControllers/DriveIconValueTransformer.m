//
//  DriveIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 01/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "DriveIconValueTransformer.h"

@implementation DriveIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
	/*
	NSString *icon = [value stringValue];
    //NSLog(@"%ld", _icon);
    
    if ([icon isEqualToString:@"hd"]) {
        return [NSImage imageNamed:@"FinderGrey.icns"];
    }
    
    if ([icon isEqualToString:@"sheepshaver"]) {
        return [NSImage imageNamed:@"FinderBlue.icns"];
    }
	*/
	return [NSImage imageNamed:@"Drive.icns"];
}

@end