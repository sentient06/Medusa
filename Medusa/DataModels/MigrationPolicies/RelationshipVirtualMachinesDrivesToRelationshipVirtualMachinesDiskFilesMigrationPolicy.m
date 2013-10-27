//
//  RelationshipVirtualMachinesDrivesToRelationshipVirtualMachinesDiskFilesMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 19/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "RelationshipVirtualMachinesDrivesToRelationshipVirtualMachinesDiskFilesMigrationPolicy.h"

@implementation RelationshipVirtualMachinesDrivesToRelationshipVirtualMachinesDiskFilesMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    // Create a new object for the model context
    NSManagedObject * newObject = 
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] 
                                  inManagedObjectContext:[manager destinationContext]];
    
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"positionIndex"];
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    return YES;
}

@end
