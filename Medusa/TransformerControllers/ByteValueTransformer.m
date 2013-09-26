//
//  ByteValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 26/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "ByteValueTransformer.h"

@implementation ByteValueTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {

    float floatSize = [value floatValue];

	if (floatSize<1023)
		return [NSString stringWithFormat:@"%i bytes", floatSize];

	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return [NSString stringWithFormat:@"%1.1f KB", floatSize];

	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return [NSString stringWithFormat:@"%1.1f MB", floatSize];

	floatSize = floatSize / 1024;
	return [NSString stringWithFormat:@"%1.1f GB", floatSize];

}

@end
