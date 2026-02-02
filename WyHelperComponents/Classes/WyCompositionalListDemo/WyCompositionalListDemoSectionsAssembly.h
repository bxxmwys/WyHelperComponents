//
//  WyCompositionalListDemoSectionsAssembly.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <Foundation/Foundation.h>

#import "WyCompositionalListSection.h"

NS_ASSUME_NONNULL_BEGIN

/// Demo 的唯一装配入口：增删/调整 Section 只改这个文件
@interface WyCompositionalListDemoSectionsAssembly : NSObject

+ (NSArray<id<WyCompositionalListSection>> *)buildSections;

@end

NS_ASSUME_NONNULL_END

