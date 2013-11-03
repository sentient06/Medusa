//
//  HelpDocumentationController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 03/11/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "HelpDocumentationController.h"

@implementation HelpDocumentationController

OSStatus goToHelpPage(CFStringRef pagePath, CFStringRef anchorName) {

    CFBundleRef myApplicationBundle = NULL;
    CFStringRef myBookName = NULL;
    OSStatus err = noErr;
    
    myApplicationBundle = CFBundleGetMainBundle();// 1
    if (myApplicationBundle == NULL) {
        err = fnfErr;
        goto bail;
    }// 2
    
    myBookName = CFBundleGetValueForInfoDictionaryKey(// 3
        myApplicationBundle,
        CFSTR("CFBundleHelpBookName")
    );

    if (myBookName == NULL) {
        err = fnfErr;
        goto bail;
    }
    
    if (CFGetTypeID(myBookName) != CFStringGetTypeID())// 4
        err = paramErr;
    
//    if (err == noErr)
//        err = AHGotoPage(myBookName, pagePath, anchorName);// 5

    bail:
    return err;
    
}

+ (void)openHelpPage:(NSString *)page {

    goToHelpPage(CFSTR("01.html"), NULL);
    
//    NSString * helpBookName = [[
//      [NSBundle mainBundle] infoDictionary
//    ] objectForKey:@"CFBundleHelpBookName"];
//    
//    [[NSWorkspace sharedWorkspace] openURLs:
    
//    NSLog(@"%@", [[NSBundle mainBundle] infoDictionary]);
//    AHGotoPage( (CFStringRef)helpBookName, (CFStringRef)page, nil );
}

@end
