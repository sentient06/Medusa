//
//  InformationModel.m
//  TableWithImages
//
//  Created by Giancarlo Mariot on 29/02/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "TableLineInformationController.h"

@implementation TableLineInformationController

@synthesize lineTitle;
@synthesize lineIcon;

- (void)dealloc {
    [lineTitle release];
    [lineIcon release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        lineTitle = [[NSString alloc] initWithFormat:@"None"];
        lineIcon = [NSImage imageNamed:@"GenericQuestionMarkIcon.icns"];
    }
    return self;
}

- (id)initWithTitle:(NSString*)newTitle
            andIcon:(NSString*)newImage {
    self = [super init];
    if (self) {
        lineTitle = [[NSString alloc] initWithFormat:newTitle];
        lineIcon = [NSImage imageNamed:newImage];
    }
    return self;
}

@end
