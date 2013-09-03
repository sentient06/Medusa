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
//    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"NoiseGrey.png"]] set];
//    NSRectFill(dirtyRect);
    
    NSGraphicsContext * theContext = [NSGraphicsContext currentContext];
//    [theContext saveGraphicsState];
    [theContext setPatternPhase:NSMakePoint(0,[self frame].size.height)];
    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"NoiseGrey.png"]] set];
    NSRectFill(dirtyRect);
//    NSRectFill([self bounds]);
//    [theContext restoreGraphicsState]; 
}

@end
