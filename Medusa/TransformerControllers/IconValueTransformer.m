//
//  IconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 13/04/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "IconValueTransformer.h"

@implementation IconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
	
	NSInteger _icon = [value intValue];
    //NSLog(@"%ld", _icon);
    
    switch (_icon) {
        default:
        case 1:
//            return [NSImage imageNamed:@"GenericQuestionMarkIcon.icns"];
//            break;
            
        case 2:
            return [NSImage imageNamed:@"FinderGrey.icns"];
            break;
            
        case 3:
            return [NSImage imageNamed:@"FinderBlue.icns"];
            break;
    }
	
	return [NSImage imageNamed:@"GenericQuestionMarkIcon.icns"];
}

@end
