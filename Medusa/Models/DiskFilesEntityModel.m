//
//  DiskFilesEntityModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
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

#import "DiskFilesEntityModel.h"
#import "RelationshipVirtualMachinesDiskFilesEntityModel.h"
#import "FileManager.h"

@implementation DiskFilesEntityModel

@synthesize bootable = _bootable;
@synthesize forceBootable = _forceBootable;
@synthesize canBoot = _canBoot;

@dynamic blocked;
@dynamic capacity;
@dynamic format;
@dynamic partitions;
@dynamic type;
@dynamic size;
@dynamic virtualMachines;
@dynamic fileName;
@dynamic fileAlias;

- (void)changeType:(int)newType {
    [self setType:[NSNumber numberWithInt:newType]];
}

- (NSString *)description {
    return [self fileName];
}

- (NSString *)filePath {
    return [FileManager resolveAlias:[self fileAlias]];
}

- (NSNumber *)bootable {
    return _bootable;
}

- (NSNumber *)forceBootable {
    return _forceBootable;
}

- (NSNumber *)canBoot {
    if (_canBoot == nil)
        if ([_forceBootable intValue] == 1)
            return _forceBootable;
        else
            return _bootable;
    else
        return _canBoot;
}

- (void)setCanBoot:(NSNumber *)canBoot {
    _canBoot = canBoot;
}

- (void)setBootable:(NSNumber *)bootable {
    _bootable = bootable;
    if ([self forceBootable])
        [self setCanBoot:[NSNumber numberWithBool:YES]];
    else
        [self setCanBoot:bootable];
}

- (void)setForceBootable:(NSNumber *)forceBootable {
    _forceBootable = forceBootable;
    [self setCanBoot:forceBootable];
}


@end
