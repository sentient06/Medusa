//
//  FileHandler.h
//  ROMan
//
//  Created by Giancarlo Mariot on 27/02/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandler : NSObject {
@private
    NSString *fileDetails;
    NSString *comments;
}

@property (copy) NSString *fileDetails, *comments;

- (void) readRomFileFrom:(NSString*)filePath;
//- (void) readDiskFileFrom:(NSString*)filePath;

@end
