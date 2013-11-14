//
//  EmulatorsEntityModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 27/09/2013.
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

#import <CoreData/CoreData.h>

enum emulatorfamily {
    undefinedFamily   = 0,
    miniVMacFamily    = 1,
    basiliskFamily    = 2,
    sheepshaverFamily = 3
};

// I decided to insert a shitload of emulators here to avoid annoying data
// migration codes. I don't expect to use more than a handful of these anyway,
// given that ROM files are not necessary for more recent emulators.
enum EmulatorTypes {
    EmulatorUnsupported = 0
  , vMacStandard
  , vMacModelCompilation
  , vMacOther1
  , vMacOther2
  , BasiliskII
  , BasiliskIIOther1
  , BasiliskIIOther2
  , vMacStandardAndBasiliskII
  , vMacModelCompilationAndBasiliskII
  , EmulatorCombo1
  , EmulatorCombo2
  , Sheepshaver
  , SheepshaverOther1
  , SheepshaverOther2
};

@class VirtualMachinesEntityModel;

@interface EmulatorsEntityModel : NSManagedObject

@property (nonatomic, retain) NSNumber * family;
@property (nonatomic, retain) NSNumber * maintained;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * readablePath;
@property (nonatomic, retain) NSString * unixPath;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSSet    * machines;

@end

@interface EmulatorsEntityModel (CoreDataGeneratedAccessors)

- (void)addMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)removeMachinesObject:(VirtualMachinesEntityModel *)value;
- (void)addMachines:(NSSet *)values;
- (void)removeMachines:(NSSet *)values;

@end
