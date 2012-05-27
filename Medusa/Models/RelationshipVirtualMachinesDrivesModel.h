//
//  RelationshipVirtualMachinesDrivesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DrivesModel, VirtualMachinesModel;

@interface RelationshipVirtualMachinesDrivesModel : NSManagedObject

@property (nonatomic, retain) NSNumber * bootable;
@property (nonatomic, retain) DrivesModel *drive;
@property (nonatomic, retain) VirtualMachinesModel *virtualMachine;

@end
