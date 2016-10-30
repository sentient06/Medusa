//
//  EmulatorIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 29/10/2016.
//  Copyright (c) 2016 Giancarlo Mariot. All rights reserved.
//

#import "EmulatorIconValueTransformer.h"
#import "EmulatorsModel.h"

@implementation EmulatorIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    
    int iconValue = [value intValue];
    
    if (iconValue == sheepshaverFamily)
        return [NSImage imageNamed:@"SS16.png"];
    
    if (iconValue == basiliskFamily)
        return [NSImage imageNamed:@"B216.png"];
    
    return [NSImage imageNamed:@"MiniMacBW.png"];
    
}

@end
