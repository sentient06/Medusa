//
//  RomFilesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VirtualMachinesModel;

@interface RomFilesModel : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * emulator;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSSet *machines;
@end

@interface RomFilesModel (CoreDataGeneratedAccessors)

- (void)addMachinesObject:(VirtualMachinesModel *)value;
- (void)removeMachinesObject:(VirtualMachinesModel *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;
@end
