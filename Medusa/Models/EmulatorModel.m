//
//  EmulatorModel.m
//  Medusa
//
//  Created by Gian2 on 30/09/2014.
//  Copyright (c) 2014 Giancarlo Mariot. All rights reserved.
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

#import "EmulatorModel.h"
#import "EmulatorsEntityModel.h"

//------------------------------------------------------------------------------

@implementation EmulatorModel

+ (int)familyFromEmulatorType:(int)type {
    switch (type) {
        case EmulatorUnsupported:
            return noFamily;
            break;
        case vMacStandard:
        case vMacModelCompilation:
        case vMacOther1:
        case vMacOther2:
            return miniVMacFamily;
            break;
        case BasiliskII:
        case BasiliskIIOther1:
        case BasiliskIIOther2:
            return basiliskFamily;
            break;
        case vMacStandardAndBasiliskII:
        case vMacModelCompilationAndBasiliskII:
            return m68kFamily;
            break;
        case Sheepshaver:
        case SheepshaverOther1:
        case SheepshaverOther2:
            return sheepshaverFamily;
            break;
   }
    return undefinedFamily;
}

+ (NSArray *)fetchAllAvailableEmulatorsForEmulatorType:(int)emulatorType {

    int emulatorFamily = [EmulatorModel familyFromEmulatorType:emulatorType];
    //----------------------------------------------------------------------
    // Core-data part:

    NSManagedObjectContext * managedObjectContext = [[NSApp delegate] managedObjectContext];
    NSError  * error;

    NSFetchRequest      * request   = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity    = [
        NSEntityDescription entityForName:@"Emulators"
            inManagedObjectContext:managedObjectContext
    ];
    NSPredicate * predicate = [ NSPredicate
        predicateWithFormat: @"family = %d", emulatorFamily
    ];

    [request setEntity:entity];
    [request setPredicate: predicate];

    NSArray * drivesResult = [managedObjectContext executeFetchRequest:request error:&error];

    [request release];

    //----------------------------------------------------------------------
    return drivesResult;
}

@end
