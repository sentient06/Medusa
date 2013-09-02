//
//  VMList.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/08/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "VMList.h"

@implementation VMList

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"NoiseGrey.png"]] set];
    NSRectFill(dirtyRect);
}

@end
