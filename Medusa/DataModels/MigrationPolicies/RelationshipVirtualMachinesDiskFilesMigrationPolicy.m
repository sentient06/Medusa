//
//  RelationshipVirtualMachinesDiskFilesMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 14/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "RelationshipVirtualMachinesDiskFilesMigrationPolicy.h"

@implementation RelationshipVirtualMachinesDiskFilesMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    
    NSLog(@"Migrating RelDiskVMs...");

    // Create a new object for the model context
    NSManagedObject * newObject = 
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] 
                                  inManagedObjectContext:[manager destinationContext]];
    
    // All the same:
    
    BOOL bootableValue = [[sInstance valueForKey:@"bootable"] boolValue];

    if (bootableValue) {
        [newObject setValue:[NSNumber numberWithInt:0] forKey:@"positionIndex"];
    } else {
        [newObject setValue:[NSNumber numberWithInt:1] forKey:@"positionIndex"];
    }

    [newObject setValue:[sInstance valueForKey:@"drive"] forKey:@"drive"];
    [newObject setValue:[sInstance valueForKey:@"virtualMachine"] forKey:@"virtualMachine"];
    
    // do the coupling of old and new
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    NSLog(@"RelDiskVMs migrated.");
    
    return YES;
}

@end
