//
//  VirtualMachinesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RelationshipVirtualMachinesDrivesModel, RomFilesModel, SharesModel;

@interface VirtualMachinesModel : NSManagedObject

@property (nonatomic, retain) NSNumber * displayHeight;
@property (nonatomic, retain) NSNumber * displayWidth;
@property (nonatomic, retain) NSNumber * fullScreen;
@property (nonatomic, retain) NSNumber * icon;
@property (nonatomic, retain) NSNumber * jitEnabled;
@property (nonatomic, retain) NSNumber * memory;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *drives;
@property (nonatomic, retain) RomFilesModel *model;
@property (nonatomic, retain) SharesModel *sharedFolder;
@end

@interface VirtualMachinesModel (CoreDataGeneratedAccessors)

- (void)addDrivesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)removeDrivesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)addDrives:(NSSet *)values;
- (void)removeDrives:(NSSet *)values;
@end
