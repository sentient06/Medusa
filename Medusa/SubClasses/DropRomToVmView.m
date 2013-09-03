//
//  DropRomToVmView.m
//  Medusa
//
//  Created by Giancarlo Mariot on 03/09/2013.
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

#import "DropRomToVmView.h"
#import "RomModel.h"
#import "VirtualMachinesModel.h"
#import "VirtualMachineWindowController.h"

@implementation DropRomToVmView

@synthesize lastRomParsed;

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  
    NSPasteboard * pboard    = [sender draggingPasteboard];
    NSArray      * urls      = [pboard propertyListForType:NSFilenamesPboardType];
    RomModel     * romObject = [[RomModel alloc] autorelease];
    
    [romObject parseRomFilesAndSave:urls];
    
    lastRomParsed = [romObject currentRomObject];
    
    // Messy!
    //http://stackoverflow.com/questions/18596164/cocoa-how-to-get-entity-used-in-interface
    VirtualMachineWindowController * parentController = [[[self window] windowController] owner];
    VirtualMachinesModel * currentMachine = [parentController virtualMachine];
    // Really messy!
    
    [currentMachine setRomFile:lastRomParsed];
    
    return YES;
    
}

@end
