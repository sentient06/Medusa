//
//  VMListTextCell.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/08/2013.
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

#import "VMListTextCell.h"

@implementation VMListTextCell

- (void)drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:bounds];
    titleRect = NSInsetRect(titleRect, 0, 8);
    NSAttributedString * title = [self attributedStringValue];
    if (title) [title drawInRect:titleRect];

//    if ([self isHighlighted]) {
//        [[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5] set];
//        [[NSColor colorWithDeviceRed:0.29 green:0.27 blue:0.42 alpha:1] set];
//    }
    
}

//- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//    return nil; //[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5];
//}
/*
- (void)drawInRect:(NSRect)aRect withAttributes:(NSDictionary *)attributes {
    [[self title] drawInRect:aRect withAttributes:nil];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
    if([self isHighlighted])
        colour = [NSColor colorWithDeviceRed:0 green:255 blue:0 alpha:0.5];
    else
        colour = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
    cellFrame.size.width += 5;
    [colour set];
    NSRectFill(cellFrame);
    [[self title] drawInRect:cellFrame withAttributes:nil];
}
*/
/*
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if( [self isHighlighted] ) {
		NSColor *oldColor = [self textColor];
		[self setTextColor:[NSColor alternateSelectedControlTextColor]];
		[super drawWithFrame:cellFrame inView:controlView];
		[self setTextColor:oldColor];
	} else {
		[super drawWithFrame:cellFrame inView:controlView];
	}
}

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    return nil;
}
*/
@end
