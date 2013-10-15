//
//  VirtualMachinesMigrationPolicy.m
//  Medusa
//
//  Created by Giancarlo Mariot on 14/10/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "VirtualMachinesMigrationPolicy.h"

@implementation VirtualMachinesMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    // Create a new object for the model context
    NSManagedObject * newObject = 
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName] 
                                  inManagedObjectContext:[manager destinationContext]];

    NSLog(@"Migrating VMs...");
    
    // All the same:

    [newObject setValue:[sInstance valueForKey:@"drives"         ] forKey:@"drives"         ];
    [newObject setValue:[sInstance valueForKey:@"romFile"        ] forKey:@"romFile"        ];
    [newObject setValue:[sInstance valueForKey:@"displayHeight"  ] forKey:@"displayHeight"  ];
    [newObject setValue:[sInstance valueForKey:@"displayWidth"   ] forKey:@"displayWidth"   ];
    [newObject setValue:[sInstance valueForKey:@"name"           ] forKey:@"name"           ];
    [newObject setValue:[sInstance valueForKey:@"sharedFolder"   ] forKey:@"sharedFolder"   ];
    [newObject setValue:[sInstance valueForKey:@"useDefaultShare"] forKey:@"useDefaultShare"];

    // Not-compulsory to Compulsory:
    
    
    if ([sInstance valueForKey:@"shareEnabled"] == nil)
        [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"shareEnabled"];
    else
        [newObject setValue:[sInstance valueForKey:@"shareEnabled"] forKey:@"shareEnabled"];
    
    if ([sInstance valueForKey:@"memory"] == nil)
        [newObject setValue:[NSNumber numberWithInt:32] forKey:@"memory"];
    else
        [newObject setValue:[sInstance valueForKey:@"memory"] forKey:@"memory"];
    
    if ([sInstance valueForKey:@"jitEnabled"] == nil)
        [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"jitEnabled"];
    else
        [newObject setValue:[sInstance valueForKey:@"jitEnabled"] forKey:@"jitEnabled"];
    
    if ([sInstance valueForKey:@"fullScreen"] == nil)
        [newObject setValue:[NSNumber numberWithBool:NO] forKey:@"fullScreen"];
    else
        [newObject setValue:[sInstance valueForKey:@"fullScreen"] forKey:@"fullScreen"];
    
    
    // New items:

    [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"displayDynamicUpdate"];
    [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"fpuEnabled"          ];
    [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"lazyCacheEnabled"    ];
    [newObject setValue:[NSNumber numberWithBool:YES] forKey:@"rawKeycodes"         ];
    [newObject setValue:[NSNumber numberWithBool:NO]  forKey:@"network"             ];
    [newObject setValue:[NSNumber numberWithBool:NO]  forKey:@"networkTap0"         ];
    [newObject setValue:[NSNumber numberWithBool:NO]  forKey:@"networkUDP"          ];
//    [newObject setValue:[NSNumber numberWithBool:NO]  forKey:@"running"             ];

    [newObject setValue:[NSNumber numberWithInt:2] forKey:@"displayColourDepth"  ];
    [newObject setValue:[NSNumber numberWithInt:8] forKey:@"displayFrameSkip"    ];
    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"emulator"            ];

    [newObject setValue:[NSNumber numberWithInt:8192] forKey:@"jitCacheSize"        ];
    [newObject setValue:[NSNumber numberWithInt:5] forKey:@"keyboardLayout"      ];
    [newObject setValue:[NSNumber numberWithInt:6066] forKey:@"networkUDPPort"      ];
    [newObject setValue:[NSNumber numberWithInt:4] forKey:@"processorType"       ];
//    [newObject setValue:[NSNumber numberWithInt:0] forKey:@"taskPID"             ];

    
    // Different value references:

    [newObject setValue:[NSString stringWithFormat:@"vm%d", CFAbsoluteTimeGetCurrent()] forKey:@"uniqueName"];

    int convertedModel = [[sInstance valueForKey:@"macModel"] intValue] + 6;    
    [newObject setValue:[NSNumber numberWithInt:convertedModel] forKey:@"macModel"]; // +6
    
    
    // do the coupling of old and new
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    NSLog(@"VMs migrated.");
    
    return YES;
}

@end
