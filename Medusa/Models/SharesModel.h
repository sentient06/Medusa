//
//  SharesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VirtualMachinesModel;

@interface SharesModel : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet *virtualMachines;
@end

@interface SharesModel (CoreDataGeneratedAccessors)

- (void)addVirtualMachinesObject:(VirtualMachinesModel *)value;
- (void)removeVirtualMachinesObject:(VirtualMachinesModel *)value;
- (void)addVirtualMachines:(NSSet *)values;
- (void)removeVirtualMachines:(NSSet *)values;
@end
