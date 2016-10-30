//
//  MiniRomIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 28/10/2016.
//  Copyright (c) 2016 Giancarlo Mariot. All rights reserved.
//

#import "MiniRomIconValueTransformer.h"
#import "RomFilesEntityModel.h"

@implementation MiniRomIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    
    int iconValue = [value intValue];
    
    if (iconValue == DeadMac)
        return [NSImage imageNamed:@"MiniMacFL.png"];
    
    if (iconValue == BlackAndWhiteHappyMac)
        return [NSImage imageNamed:@"MiniMacBW.png"];
    
    if (iconValue == ColouredHappyMac)
        return [NSImage imageNamed:@"MiniMacCL.png"];
    
    if (iconValue == MiniVMacMac)
        return [NSImage imageNamed:@"MiniMacBW.png"];
    
    return [NSImage imageNamed:@"MiniMacFL.png"];
    
}

@end
