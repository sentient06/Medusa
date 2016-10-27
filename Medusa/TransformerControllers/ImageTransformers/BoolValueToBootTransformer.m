//
//  BoolValueToBootTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 25/10/2016.
//  Copyright (c) 2016 Giancarlo Mariot. All rights reserved.
//

#import "BoolValueToBootTransformer.h"

@implementation BoolValueToBootTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    if ([value intValue] == 1)
        return [NSImage imageNamed:@"boot.png"];
    else return nil;
}

@end
