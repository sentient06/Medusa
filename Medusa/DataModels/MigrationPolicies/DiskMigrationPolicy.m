//
//  DiskMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 14/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "DiskMigrationPolicy.h"

@implementation DiskMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    NSLog(@"Migrating Disks...");

    // Create a new object for the model context
    NSManagedObject * newObject = 
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] 
                                  inManagedObjectContext:[manager destinationContext]];

    // Not-compulsory to Compulsory:

    if ([sInstance valueForKey:@"fileName"] == nil)
        [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"fileName"];
    else
        [newObject setValue:[sInstance valueForKey:@"fileName"] forKey:@"fileName"];

    if ([sInstance valueForKey:@"filePath"] == nil)
        [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"filePath"];
    else
        [newObject setValue:[sInstance valueForKey:@"filePath"] forKey:@"filePath"];
    
    // New items:
    
    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"blocked" ];
    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"bootable"];
    
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"capacity"];
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"size"    ];    
    
    // do the coupling of old and new
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    NSLog(@"Disks migrated.");
    
    return YES;
}

@end
