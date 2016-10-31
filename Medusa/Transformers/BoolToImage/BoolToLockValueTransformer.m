//
//  BoolToLockValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 23/10/2016.
//  Copyright (c) 2016 Giancarlo Mariot. All rights reserved.
//

#import "BoolToLockValueTransformer.h"

@implementation BoolToLockValueTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    if ([value intValue] == 1)
        return [NSImage imageNamed:@"NSLockLockedTemplate"];
    else return nil;
}

@end
