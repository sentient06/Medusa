//
//  BoolValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 26/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "BoolValueTransformer.h"

@implementation BoolValueTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    if ([value intValue] == 1)
         return @"YES";
    else return @"NO";
}

@end
