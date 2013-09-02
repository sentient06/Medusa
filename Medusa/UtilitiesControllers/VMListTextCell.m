//
//  VMListTextCell.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/08/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "VMListTextCell.h"

@implementation VMListTextCell

- (void)drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView {

    NSRect titleRect = [self titleRectForBounds:bounds];
    
    titleRect = NSInsetRect(titleRect, 0, 8);
    
    NSAttributedString * title = [self attributedStringValue];
    
    if (title)
        [title drawInRect:titleRect];
    
   
}

@end
