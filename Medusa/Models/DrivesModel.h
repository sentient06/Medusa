//
//  DrivesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RelationshipVirtualMachinesDrivesModel;

@interface DrivesModel : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *virtualMachines;
@end

@interface DrivesModel (CoreDataGeneratedAccessors)

- (void)addVirtualMachinesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)removeVirtualMachinesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)addVirtualMachines:(NSSet *)values;
- (void)removeVirtualMachines:(NSSet *)values;

//Test
//+ (NSEntityDescription**) insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)value;

@end
