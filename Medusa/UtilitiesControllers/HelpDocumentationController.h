//
//  HelpDocumentationController.h
//  Medusa
//
//  Created by Giancarlo Mariot on 03/11/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

@interface HelpDocumentationController : NSObject

OSStatus goToHelpPage (CFStringRef pagePath, CFStringRef anchorName);
+ (void)openHelpPage:(NSString *)page;

@end
