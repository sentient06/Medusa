//
//  NSManagedObject+clone.m
//  Medusa
//
//  Created by Giancarlo Mariot on 02/07/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------

#import "NSManagedObject+clone.h"

@implementation NSManagedObject (DeepCopy)

- (id)clone {
    
    NSString * entityName = [[self entity] name];
    
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];
    
    // Creates new object in data store
    NSManagedObject * cloned = [
                    NSEntityDescription
        insertNewObjectForEntityForName:entityName
                 inManagedObjectContext:managedObjectContext
    ];
    
    // Loops through all attributes and assigns them to the clone
    NSDictionary * attributes = [[
           NSEntityDescription
                 entityForName:entityName
        inManagedObjectContext:managedObjectContext
    ] attributesByName ];
    
    for (NSString * attr in attributes) {
        [cloned setValue:[self valueForKey:attr] forKey:attr];
    }
    
    // Loops through all relationships, and clone them.
    NSDictionary * relationships = [[
           NSEntityDescription
                 entityForName:entityName
        inManagedObjectContext:managedObjectContext
    ] relationshipsByName ];
    
    for (NSString * relName in [relationships allKeys]){
        NSRelationshipDescription * rel = [relationships objectForKey:relName];
        
        if ([rel isToMany]) {
            // Gets a stack of all objects in the relationship
            NSArray *sourceArray = [[self mutableSetValueForKey:relName] allObjects];
            NSMutableSet *clonedSet = [cloned mutableSetValueForKey:relName];
            for(NSManagedObject *relatedObject in sourceArray) {
                NSManagedObject *clonedRelatedObject = [relatedObject clone];
                [clonedSet addObject:clonedRelatedObject];
            }
        } else {
            [cloned setValue:[self valueForKey:relName] forKey:relName];
        }
        
    }
    
    return cloned;
}


@end
