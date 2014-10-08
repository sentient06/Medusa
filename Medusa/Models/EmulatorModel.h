//
//  EmulatorModel.h
//  Medusa
//
//  Created by Gian2 on 30/09/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmulatorModel : NSObject

+ (int)familyFromEmulatorType:(int)type;
+ (NSArray *)fetchAllAvailableEmulatorsForEmulatorType:(int)emulatorType;

@end
