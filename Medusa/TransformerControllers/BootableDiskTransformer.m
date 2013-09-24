//
//  BootableDiskTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 24/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "BootableDiskTransformer.h"

@implementation BootableDiskTransformer

+ (Class)transformedValueClass {
    return [NSNumber class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    if ([value intValue] == 0) return [NSNumber numberWithBool:YES];
    return [NSNumber numberWithBool:NO];
}

@end
