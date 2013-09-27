//
//  EmulatorsEntityModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 27/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import <CoreData/CoreData.h>

enum emulatorfamily {
    undefinedFamily   = 0,
    miniVMacFamily    = 1,
    basiliskFamily    = 2,
    sheepshaverFamily = 3
};

@class VirtualMachinesEntityModel;

@interface EmulatorsEntityModel : NSManagedObject

@property (nonatomic, retain) NSNumber * family;
@property (nonatomic, retain) NSNumber * maintained;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * unixPath;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSSet    * machines;

@end

@interface EmulatorsEntityModel (CoreDataGeneratedAccessors)

- (void)addMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)removeMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;

@end
