//
//  CoreDataModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 04/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VirtualMachinesModel;

@interface PreferencesModel : NSObject {
    NSManagedObjectContext *managedObjectContext;
}

//------------------------------------------------------------------------------
// Manual getters
- (NSManagedObjectContext *)managedObjectContext;

// Manual setters
- (void)setManagedObjectContext:(NSManagedObjectContext *)value;

//------------------------------------------------------------------------------
- (void)insertNewVirtualMachineWithData:(NSDictionary*)newData;
- (void)insertNewData:(NSDictionary*)newData inVirtualMachine:(NSManagedObject*)virtualMachine;

- (NSMutableArray*)getVirtualMachineData:(VirtualMachinesModel*)virtualMachine;
- (void)savePreferencesFile:(NSArray*)dataToSave ForFile:(NSString*)filePath;

@end
