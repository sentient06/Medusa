//
//  driveFormatValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 26/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "DriveFormatValueTransformer.h"
#import "DiskFilesEntityModel.h"

@implementation DriveFormatValueTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}
+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    
    switch ([value intValue]) {
        case formatLisaFS  :
            return @"Lisa FS";
            
        case formatMFS:
            return @"MFS";
            
        case formatHFS:
            return @"HFS";
            
        case formatHFSPlus:
            return @"HFS+";
            
        case formatISO9660:
            return @"ISO 9660";
            
        case formatFAT:
            return @"FAT";
            
        case formatOther:
            return @"Unknown file system";
            
        case formatUnknown:
            return @"No file system detected";
            
        case formatMisc:
            return @"Miscellaneous file systems";

    }
    
    return @"No file system";
    
}

@end
