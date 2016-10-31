//
//  VMListButtonCell.m
//  Medusa
//
//  Created by Gian2 on 10/10/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import "VMListButtonCell.h"

// pragma GCC diagnostic ignored "-Wundeclared-selector"

@implementation VMListButtonCell

- (BOOL)showsBorderOnlyWhileMouseInside {
    return YES;
}

- (void)mouseEntered:(NSEvent *)event {
    [self setImage:[NSImage imageNamed:@"ToggleOnUp"]];
}


// http://everythingfrontend.com/posts/cocoa-custom-checkbox-button.html
- (void)drawImage:(NSImage *)image
        withFrame:(NSRect)frame
           inView:(NSView *)controlView {

    
    NSString * imageName; // = [[[NSString alloc] init] autorelease];
    
    if([self intValue]) {
        if ([self isEnabled]) {
            imageName = @"ToggleOnUp.png";
        } else {
            imageName = @"ToggleOnUp.png";
        }
    } else {
        if ([self isEnabled]) {
            imageName = @"ToggleOffUp.png";
        } else {
            imageName = @"ToggleOffUp.png";
        }
    }
//     if([self isEnabled]) {
//         if([self intValue]) {
//             imageName = @"ToggleOffUp.png";
//             NSLog(@"1");
//         } else {
//             imageName = @"ToggleOffDown.png";
//             NSLog(@"2");
//         }
//     } else {
//         if([self intValue]) {
//             imageName = @"ToggleOnUp.png";
//             NSLog(@"3");
//         } else {
//             imageName = @"ToggleOnDown.png";
//             NSLog(@"4");
//         }
//     }
    
    NSImage * bimage = [NSImage imageNamed:imageName];
    
//    [bimage lockFocusFlipped:YES];
    
    [bimage drawInRect:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
              fromRect:NSZeroRect
             operation:NSCompositeSourceOver
              fraction:1
        respectFlipped:YES
                 hints:nil
    ];
    
//    [bimage drawInRect: NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
//              fromRect: NSZeroRect
//             operation: NSCompositeSourceOver fraction:1.0f];
    
/*
//    [[NSColor colorWithDeviceRed:255 green:255 blue:255 alpha:0] setFill];
    [[NSColor whiteColor] setFill];
    NSRectFill(frame);
    
    
    NSRect fillFrame = NSInsetRect(frame, 4, 4);
    
//    [[NSColor whiteColor] setFill];
//    NSRectFill(fillFrame);
    
    NSGraphicsContext * theContext = [NSGraphicsContext currentContext];
    [theContext setPatternPhase:NSMakePoint(0,23)]; //frame.size.height)];
    
    
    
    NSImage * toggleImage = [NSImage imageNamed:@"Clone.png"];
    [toggleImage setScalesWhenResized:YES];
    [toggleImage setBackgroundColor:[NSColor colorWithDeviceRed:255 green:0 blue:0 alpha:1]];
    NSSize newSize;
    newSize.width = 16;
    newSize.height = 16;
    [toggleImage setSize:newSize];
    [[NSColor colorWithPatternImage:toggleImage] setFill];
    
    NSRectFill(fillFrame);
*/
//    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"ToggleOffUp.png"]] set];
    
    
    /*
    // Drawing border
    if(![self isEnabled]) {
        [[NSColor lightGrayColor] setFill];
    } else {
        [[NSColor grayColor] setFill];
    }
    NSRectFill(NSInsetRect(frame, 2, 2));
    
    // Drawing inner contents
    NSRect fillFrame = NSInsetRect(frame, 4, 4);

    if([self isHighlighted]) {
//        NSImage * image = [NSImage imageNamed:@"ToggleOnUp"];
//        [image setScalesWhenResized:YES];
//        NSSize newSize;
//        newSize.width =28;
//        newSize.height = 28;
//        [image setSize:newSize];
//        [[NSColor colorWithPatternImage:image] setFill];
        [[NSColor colorWithCalibratedWhite:0.9f alpha:1.0f] setFill];
    } else {
        [[NSColor colorWithCalibratedWhite:0.8f alpha:1.0f] setFill];
    }
    NSRectFill(fillFrame);

    // Now drawing tick
    if ([self intValue]) {
        if(![self isEnabled]) {
            [[NSColor grayColor] setFill];
        } else {
            [[NSColor colorWithPatternImage:[NSImage imageNamed:@"ToggleOnUp.png"]] setFill];
        }
        NSRectFill(NSInsetRect(frame, 6, 6));
    }
    */
    
//    NSGraphicsContext * theContext = [NSGraphicsContext currentContext];
//    [theContext setPatternPhase:NSMakePoint(0,[self frame].size.height)];
//    [[NSColor colorWithPatternImage:[NSImage imageNamed:@"linenPattern.png"]] set];
//    NSRectFill(dirtyRect);
    
}


@end
