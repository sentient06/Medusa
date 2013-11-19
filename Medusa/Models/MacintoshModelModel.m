//
//  MacintoshModelModel.m
//  Medusa
//
//  Created by Giancarlo Mariot on 15/11/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//

#import "MacintoshModelModel.h"

@implementation MacintoshModelModel
@synthesize modelName, modelId;

- (void)dealloc {
    [modelId release];
    [modelName release];
}

+ (NSDictionary *)fetchAllAvailableModelsForChecksum:(uint32)gestaltId {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        @"1. Mac Classic",                  [NSNumber numberWithInt:1]
      , @"2. Mac XL",                       [NSNumber numberWithInt:2]
      , @"3. Mac 512KE",                    [NSNumber numberWithInt:3]
      , @"4. Mac Plus",                     [NSNumber numberWithInt:4]
      , @"5. Mac SE",                       [NSNumber numberWithInt:5]
      , @"6. Mac II",                       [NSNumber numberWithInt:6]
      , @"7. Mac IIx",                      [NSNumber numberWithInt:7]
      , @"8. Mac IIcx",                     [NSNumber numberWithInt:8]
      , @"9. Mac SE/030",                   [NSNumber numberWithInt:9]
      , @"10. Mac Portable",                [NSNumber numberWithInt:10]
      , @"11. Mac IIci",                    [NSNumber numberWithInt:11]
      , @"13. Mac IIfx",                    [NSNumber numberWithInt:13]
      , @"17. Mac Classic",                 [NSNumber numberWithInt:17]
      , @"18. Mac IIsi",                    [NSNumber numberWithInt:18]
      , @"19. Mac LC",                      [NSNumber numberWithInt:19]
      , @"20. Quadra 900",                  [NSNumber numberWithInt:20]
      , @"21. PowerBook 170",               [NSNumber numberWithInt:21]
      , @"22. Quadra 700",                  [NSNumber numberWithInt:22]
      , @"23. Classic II",                  [NSNumber numberWithInt:23]
      , @"24. PowerBook 100",               [NSNumber numberWithInt:24]
      , @"25. PowerBook 140",               [NSNumber numberWithInt:25]
      , @"26. Quadra 950",                  [NSNumber numberWithInt:26]
      , @"27. Mac LCIII/Performa 450",      [NSNumber numberWithInt:27]
      , @"29. PowerBook Duo 210",           [NSNumber numberWithInt:29]
      , @"30. Centris 650",                 [NSNumber numberWithInt:30]
      , @"32. PowerBook Duo 230",           [NSNumber numberWithInt:32]
      , @"33. PowerBook 180",               [NSNumber numberWithInt:33]
      , @"34. PowerBook 160",               [NSNumber numberWithInt:34]
      , @"35. Quadra 800",                  [NSNumber numberWithInt:35]
      , @"36. Quadra 650",                  [NSNumber numberWithInt:36]
      , @"37. Mac LCII",                    [NSNumber numberWithInt:37]
      , @"38. PowerBook Duo 250",           [NSNumber numberWithInt:38]
      , @"44. Mac IIvi",                    [NSNumber numberWithInt:44]
      , @"45. Mac IIvm/Performa 600",       [NSNumber numberWithInt:45]
      , @"48. Mac IIvx",                    [NSNumber numberWithInt:48]
      , @"49. Color Classic/Performa 250",  [NSNumber numberWithInt:49]
      , @"50. PowerBook 165c",              [NSNumber numberWithInt:50]
      , @"52. Centris 610",                 [NSNumber numberWithInt:52]
      , @"53. Quadra 610",                  [NSNumber numberWithInt:53]
      , @"54. PowerBook 145",               [NSNumber numberWithInt:54]
      , @"56. Mac LC520",                   [NSNumber numberWithInt:56]
      , @"60. Quadra/Centris 660AV",        [NSNumber numberWithInt:60]
      , @"62. Performa 46x",                [NSNumber numberWithInt:62]
      , @"71. PowerBook 180c",              [NSNumber numberWithInt:71]
      , @"72. PowerBook 520/520c/540/540c", [NSNumber numberWithInt:72]
      , @"77. PowerBook Duo 270c",          [NSNumber numberWithInt:77]
      , @"78. Quadra 840AV",                [NSNumber numberWithInt:78]
      , @"80. Performa 550",                [NSNumber numberWithInt:80]
      , @"84. PowerBook 165",               [NSNumber numberWithInt:84]
      , @"85. PowerBook 190",               [NSNumber numberWithInt:85]
      , @"88. Mac TV",                      [NSNumber numberWithInt:88]
      , @"89. Mac LC475/Performa 47x",      [NSNumber numberWithInt:89]
      , @"92. Mac LC575",                   [NSNumber numberWithInt:92]
      , @"94. Quadra 605",                  [NSNumber numberWithInt:94]
      , @"98. Quadra 630",                  [NSNumber numberWithInt:98]
      , @"99. Mac LC580",                   [NSNumber numberWithInt:99]
      , @"102. PowerBook Duo 280",          [NSNumber numberWithInt:102]
      , @"103. PowerBook Duo 280c",         [NSNumber numberWithInt:103]
      , @"115. PowerBook 150",              [NSNumber numberWithInt:115]
//      , @"-1. unknown",                      [NSNumber numberWithInt:-1]
      , nil];
}

- (id)initWithName:(NSString *)newName AndModelId:(NSNumber *)newModelId {
    self = [super init];
    if (self) {
        modelName = newName;
        modelId = newModelId;
    }
    return self;
}

//- (NSString *)description {
//	return [[[NSDictionary dictionaryWithObjectsAndKeys:
//             self.modelId, @"modelId",
//             self.modelName, @"modelName",
//             nil] description] autorelease];
//}

@end
