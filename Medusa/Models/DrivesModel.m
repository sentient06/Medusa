//
//  DrivesModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//

#import "DrivesModel.h"
#import "RelationshipVirtualMachinesDrivesModel.h"


@implementation DrivesModel

@dynamic fileName;
@dynamic filePath;
@dynamic type;
@dynamic virtualMachines;

//+ (NSEntityDescription*) insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)value {
//    
//    NSEntityDescription * teste = [
//        NSEntityDescription
//            insertNewObjectForEntityForName:@"Drives"
//                     inManagedObjectContext:value
//    ];
//    
//    return teste;
//    
//}

- (NSString *)description {
    return [self fileName];
}

@end
