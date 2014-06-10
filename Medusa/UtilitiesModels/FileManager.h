//
//  FileManager.h
//  Medusa
//
//  Created by Gian2 on 09/06/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (NSData *)createBookmarkFromUrl:(NSURL *)filePath;
+ (void)resolveBookmarksInObjectContext:(NSManagedObjectContext *)currentContext;
+ (NSString *)resolveAlias:(NSData *)aliasData;

@end
