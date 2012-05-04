//
//  DropView.m
//  DragDropApp
//
//  Created by Giancarlo Mariot on 28/02/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "DropView.h"
#import "FileHandler.h"
#import "AppDelegate.h"

@implementation DropView

@synthesize computerModel;
@synthesize acceptedTypes;

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric) {

        return NSDragOperationCopy;
    }else{
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    
    BOOL returnValue;
    
    //All pasteboard:
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *urls = [pboard propertyListForType:NSFilenamesPboardType];
    
    
    //Old code
    //------------------------------------
    /*
    //First element only:
    NSString *firstElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:0]];
    NSString *pathExtension = [[NSString alloc] initWithFormat:[firstElement pathExtension]];
    
    //Check if is a folder:
    BOOL isDir;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    [fileManager fileExistsAtPath:firstElement isDirectory:&isDir];
    
    NSString *kind = nil;
    NSURL *url = [NSURL fileURLWithPath:[firstElement stringByExpandingTildeInPath]];
    LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
    
    NSLog(@"%@", kind);
    computerModel = @"Test";
    //NSLog(@"%@", parent);

    if (
        [kind isEqualToString:@"Unix Executable File"] ||
        [kind isEqualToString:@"Document"]
    ) {
        returnValue = YES;
    }else{
        returnValue = NO;
    }
        
    
    [fileManager release];
    [pathExtension release];
    [firstElement release];
    
    */
    //------------------------------------
    //New code
    //First element only:
    
    NSString *firstElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:0]];
    
    NSString *currentElement;
    //NSString *pathExtension;
    BOOL isDir;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *kind;
    NSURL *url;
    
    returnValue = NO;
    
    for (int i=0; i<[urls count]; i++) {

        currentElement = [[NSString alloc] initWithFormat:[urls objectAtIndex:i]];
        //pathExtension  = [[NSString alloc] initWithFormat:[currentElement pathExtension]];

        //Check if is a folder:
        
        [fileManager fileExistsAtPath:currentElement isDirectory:&isDir];
        
        kind = nil;
        url = [NSURL fileURLWithPath:[firstElement stringByExpandingTildeInPath]];
        LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
        
        NSLog(@"%@", kind);
        computerModel = @"Test";
        
        [currentElement release];
        
        if (
            [kind isEqualToString:@"Unix Executable File"] ||
            [kind isEqualToString:@"Document"]
        ) {
            returnValue = YES;
            break;
        }
        
    }
    
    [fileManager release];
    //[pathExtension release];
    [firstElement release];
    
    return returnValue;
    
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {

    return YES;
    
}

@end
