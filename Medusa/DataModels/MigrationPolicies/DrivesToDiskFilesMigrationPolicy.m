//
//  DrivesToDiskFilesMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 19/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "DrivesToDiskFilesMigrationPolicy.h"
#import "VirtualMachinesEntityModel.h"
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h"
#import "RomFilesEntityModel.h"

@implementation DrivesToDiskFilesMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    // Create a new object for the model context
    NSManagedObject * newObject = 
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] 
                                  inManagedObjectContext:[manager destinationContext]];

    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"blocked"];
    [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"bootable"];

    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"capacity"];
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"format"];
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"partitions"];
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"size"];

    [newObject setValue:[sInstance valueForKey:@"fileName"] forKey:@"fileName"];
    [newObject setValue:[sInstance valueForKey:@"filePath"] forKey:@"filePath"];

    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    return YES;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance
                                    entityMapping:(NSEntityMapping *)mapping
                                          manager:(NSMigrationManager *)manager
                                            error:(NSError **)error
{
    
//    NSLog(@"Source model: %@", [[[[manager sourceModel] entitiesByName] objectForKey:@"Drives"] respondsToSelector:@selector(virtualMachines)] ? @"yes" : @"no");
    //------
//    KPBPerson * person = (KPBPerson *) dInstance;
//    
//    // split the name into keywords
//    NSArray *keywordStrings = [person.query componentsSeparatedByString:@" "];
//    
//    for (NSString *keywordString in keywordStrings) {
//        
//        // create a new keyword entity in the destination context
//        KPBSearchKeyword *keyword = [NSEntityDescription insertNewObjectForEntityForName:@"SearchKeyword"
//                                                                  inManagedObjectContext:manager.destinationContext];
//        keyword.term = keywordString;
//        // set the relation
//        keyword.person = person;
//    }
    
    //-----
//    return [super createRelationshipsForDestinationInstance:dInstance entityMapping:mapping manager:manager error:error];
    //-----
//    NSError * superError = nil;
//    BOOL mappingSuccess = [super createRelationshipsForDestinationInstance:dInstance entityMapping:mapping manager:manager error:&superError];
//
//    if ([dInstance.entity.name isEqualToString:@"Instance"]){
//        Instance *instance = (Instance*)dInstance;
//        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Instance"];
//        fetch.predicate = [NSPredicate predicateWithFormat:@"identifier == %@",instance.identifier];
//        NSArray *result = [manager.destinationContext executeFetchRequest:fetch];
//        Rule *rule = [result objectAtIndex:0];
//        instance.rule = rule;
//    }
    
//    oldObject
//    
//    [manager associateSourceInstance:oldObject withDestinationInstance:dInstance forEntityMapping:mapping];
    
//    return YES;
    //virtualMachines;
    //==================
    
    NSArray *relationshipMappings = [mapping relationshipMappings];
    for (NSPropertyMapping *aPropertyMapping in relationshipMappings)
    {
        NSLog(@"Property name: %@", [aPropertyMapping name]);
        /*
        if ([[aPropertyMapping name] compare:@"tuner"] != NSOrderedSame)
        {
            // The other relationships are pretty straight forward - we can just use the entityMapping from Xcode to handle them
            NSExpression *migrationExpression = [aPropertyMapping valueExpression];
            NSArray *sourceInstancesArray = [manager sourceInstancesForEntityMappingNamed:[mapping name] destinationInstances:[NSArray arrayWithObject:dInstance]];
            NSManagedObject *source = nil;
            if ([sourceInstancesArray count] > 0)
                source = [sourceInstancesArray objectAtIndex:0];
            NSMutableDictionary *context = [[[NSMutableDictionary alloc] init] autorelease];
            [context setValue:manager forKey:@"manager"];
            [context setValue:source forKey:@"source"];
            id expressionResult = [migrationExpression expressionValueWithObject:nil context:context];
            if (!expressionResult)
            {
                if (error)
                    *error = nil;
                return NO;
            }
        }
        */
    }
    
    /*
    // The new tuner relationship is more tricky - in this case we need to use the recordings schedule to find the first HDHomeRunStation for the schedule
    // then use the migration manager to find the equivalent station in the new MOC and then set up a relationship in the instance 
    NSManagedObject *schedule = [dInstance valueForKey:@"schedule"];
    NSManagedObject *tuner = nil;
    if (schedule)
    {
        NSSet *hdhrStations = [schedule valueForKeyPath:@"station.hdhrStations"];
        NSManagedObject *aHDHRStation = [hdhrStations anyObject];
        tuner = [aHDHRStation valueForKeyPath:@"channel.tuner"];
        [dInstance setValue:tuner forKey:@"tuner"];
    }
    */
    
    return YES;

}

@end
