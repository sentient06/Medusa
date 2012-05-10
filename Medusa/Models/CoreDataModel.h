//
//  CoreDataModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 04/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataModel : NSObject {
    NSManagedObjectContext *managedObjectContext;
}

- (void) insertNewVirtualMachineWithData:(NSDictionary*)newData;
- (void) insertNewData:(NSDictionary*)newData inVirtualMachine:(NSManagedObject*)virtualMachine;

- (NSMutableArray*) virtualMachineData:(NSManagedObject*)virtualMachine;

@end
