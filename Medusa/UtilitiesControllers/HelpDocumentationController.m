//
//  HelpDocumentationController.m
//  Medusa
//
//  Created by Giancarlo Mariot on 03/11/2013.
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
