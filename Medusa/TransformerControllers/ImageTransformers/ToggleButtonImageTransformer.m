//
//  ToggleButtonImageTransformer.m
//  Medusa
//
//  Created by Gian2 on 10/10/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import "ToggleButtonImageTransformer.h"

@implementation ToggleButtonImageTransformer

+ (Class)transformedValueClass {
    return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    
//    NSLog(@"%@", [value class]);
//    int running = [value intValue];
    
//    if (running == 1)
//        return [NSImage imageNamed:@"ToggleOffUp.png"];

    return [NSImage imageNamed:@"ToggleOnDown.png"];
}

@end
