//
//  VirtualMachineModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 30/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
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

#import "VirtualMachineModel.h"
#import "VirtualMachinesEntityModel.h"
#import "ManagedObjectCloner.h" //Clone core-data objects
#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_ERROR;
//------------------------------------------------------------------------------

@implementation VirtualMachineModel

- (BOOL)existsMachineNamed:(NSString *)nameToCheck {
   
    NSError * error;
    
    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [ NSEntityDescription entityForName:@"VirtualMachines" inManagedObjectContext:managedObjectContext];
    NSPredicate         * predicate = [ NSPredicate
        predicateWithFormat: @"name = %@", nameToCheck
    ];
    
    [request setEntity:entity];
    [request setPredicate: predicate];

    NSInteger resultCount = [managedObjectContext countForFetchRequest:request error:&error];
    
    [request release];
    
    if (resultCount > 0)
        return YES;       
    else
        return NO;

}

- (void)insertMachineNamed:(NSString *)newMachineName {

    int currentTime = CFAbsoluteTimeGetCurrent();
    DDLogVerbose(@"Creating machine called '%@'", newMachineName);

    //Sets a new vm object.
    VirtualMachinesEntityModel * newVirtualMachineObject = [
        NSEntityDescription
        insertNewObjectForEntityForName:@"VirtualMachines"
                 inManagedObjectContext:managedObjectContext
    ];
    
    //Here we have all the fields to be inserted.
    [newVirtualMachineObject setName:newMachineName];
    [newVirtualMachineObject setUniqueName:[NSString stringWithFormat:@"vm%d", currentTime]];
    
    // Model must be 5 or 14 IIci 7-7.5 or Quadra 900 7.5-8.1
    
    DDLogVerbose(@"%@", newVirtualMachineObject);
    
    [[NSApp delegate] saveCoreData];

}

- (void)cloneMachine:(VirtualMachinesEntityModel *)machineToClone withName:(NSString *)newMachineName {

    int currentTime = CFAbsoluteTimeGetCurrent();
    DDLogVerbose(@"Cloning machine called '%@'", [machineToClone name]);
    
    //Cloned machine:
    VirtualMachinesEntityModel * clonedMachine = [machineToClone clone];
    
    //Change name:
    [clonedMachine setName:newMachineName];
    [clonedMachine setUniqueName:[NSString stringWithFormat:@"vm%d", currentTime]];
    
    [[NSApp delegate] saveCoreData];

}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newManagedObjectContext {
    self = [super init];
    if (self) {
        managedObjectContext = newManagedObjectContext;
    }
    return self;    
}

- (void)blockDisks {
    DDLogVerbose(@"blocking disks");
}
- (void)unblockDisks {
    DDLogVerbose(@"unblocking disks");
}

@end
