//
//  WyCompositionalListDemoPageVM.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import <Foundation/Foundation.h>

#import "WyCompositionalListSectionDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Demo：同一个页面 VM 统一管理多个书架的数据
@interface WyCompositionalListDemoPageVM : NSObject <WyCompositionalListSectionDataProvider>

/// 构造一套 demo 数据（含瀑布流高度映射）
+ (instancetype)demoVM;

@end

NS_ASSUME_NONNULL_END

