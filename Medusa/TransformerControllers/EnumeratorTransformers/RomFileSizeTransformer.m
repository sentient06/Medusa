//
//  RomFileSizeTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 01/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------

#import "RomFileSizeTransformer.h"
#import "RomFilesEntityModel.h"

@implementation RomFileSizeTransformer

+ (Class)transformedValueClass {
    return [NSString class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    
    int sizeValue = [value intValue];
    
    NSLog(@"Rom size is id #%d", sizeValue);
    
    switch (sizeValue) {
            
        case rom64KB:
            return @"64K ROM";

        case rom128KB:
            return @"128K ROM";

        case rom256KB:
            return @"256K ROM";

        case rom512KB:
            return @"512K ROM";

        case rom1MB:
            return @"1MB ROM";

        case rom2MB:
            return @"2MB ROM";

        case rom3MB:
            return @"3MB ROM";

        case rom4MB:
            return @"4MB ROM";
        
        case romNull:
        default:
            return @"Unknown size";
    }
    
}

@end
