//
//  MacintoshModelModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 15/11/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MacintoshModelModel : NSObject
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSNumber * modelId;

+ (NSDictionary *)fetchAllAvailableModelsForChecksum:(uint32)gestaltId;
- (id)initWithName:(NSString *)newName AndModelId:(NSNumber *)newModelId;

@end
