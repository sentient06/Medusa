//
//  DiskFilesEntityModel.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum diskFormat {
    formatLisaFS  = 1, // Lisa File-system
    formatMFS     = 2, // Macintosh File-system
    formatHFS     = 3, // Hyerarquical File-system
    formatHFSPlus = 4, // Hyerarquical File-system Plus
    formatISO9660 = 5, // ISO 9660 - CD/DVD ROM
    formatFAT     = 6, // FAT 16, FAT 32
    formatOther   = 7, // Other FS
    formatUnknown = 8, // Unknown FS
    formatMisc    = 9  // Partitioned with different FS
};

@class RelationshipVirtualMachinesDiskFilesEntityModel;

@interface DiskFilesEntityModel : NSManagedObject

@property (nonatomic, retain) NSNumber * blocked;
@property (nonatomic, retain) NSNumber * bootable;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSNumber * format;
@property (nonatomic, retain) NSNumber * partitions;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSSet    * virtualMachines;
@property (nonatomic, retain) NSString * fileName;
//@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSData   * fileAlias;

@end

@interface DiskFilesEntityModel (CoreDataGeneratedAccessors)

- (void)addVirtualMachinesObject:(RelationshipVirtualMachinesDiskFilesEntityModel *)value;
- (void)removeVirtualMachinesObject:(RelationshipVirtualMachinesDiskFilesEntityModel *)value;
- (void)addVirtualMachines:(NSSet *)values;
- (void)removeVirtualMachines:(NSSet *)values;
- (NSString *)filePath;

@end
