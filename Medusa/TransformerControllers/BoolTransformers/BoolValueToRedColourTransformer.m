//
//  BoolValueToColourTransformer.m
//  Medusa
//
//  Created by Gian2 on 13/06/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import "BoolValueToRedColourTransformer.h"

@implementation BoolValueToRedColourTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value intValue] == 1)
        return [NSColor redColor];
    else return [NSColor blackColor];
}

@end
