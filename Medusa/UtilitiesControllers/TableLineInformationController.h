//
//  InformationModel.h
//  TableWithImages
//
//  Created by Giancarlo Mariot on 29/02/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableLineInformationController : NSObject {
    NSString    *lineTitle;
    NSImage     *lineIcon;
}

@property (copy)    NSString    *lineTitle;
@property (retain)  NSImage     *lineIcon;

- (id)initWithTitle:(NSString*)newTitle andIcon:(NSString*)newImage;

@end
