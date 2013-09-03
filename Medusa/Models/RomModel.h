//
//  RomModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 03/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

enum RomConditions {
    PerfectSheepNew        = 1,
    PerfectSheepOld        = 2,
    PerfectBasilisk        = 3,
    NoAppleTalk            = 4,
    FPURequired            = 5,
    NoAppleTalkFPURequired = 6,
    Unsupported            = 7
};

//@class RomFilesModel;

@interface RomModel : NSObject {
@private
    NSString * fileDetails;
    NSString * comments;
    int romCondition;
}

- (id)parseSingleRomFileAndSave:(NSString *)filePath inObjectContext:(NSManagedObjectContext *)currentContext;
- (void)parseRomFilesAndSave:(NSArray *)filesList;
- (void)readRomFileFrom:(NSString *)filePath; //Got from FileHandler

@end
