//
//  WyCompositionalListDemoWaterfallVM.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <Foundation/Foundation.h>

#import "WyCompositionalListSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Demo：瀑布流数据 VM（高度映射放在 VM 内，Section 只负责布局/绑定）
@interface WyCompositionalListDemoWaterfallVM : NSObject <WyCompositionalListSectionViewModel>

@property (nonatomic, copy, readonly, nullable) NSString *headerTitle;
@property (nonatomic, copy, readonly, nullable) NSString *footerTitle;

- (instancetype)initWithSectionID:(NSString *)sectionID
                           header:(nullable NSString *)header
                           footer:(nullable NSString *)footer
                          itemIDs:(NSArray<NSString *> *)itemIDs
                       heightByID:(NSDictionary<NSString *, NSNumber *> *)heightByID NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/// 获取指定 item 的高度（不存在则返回 0）
- (CGFloat)heightForItemID:(NSString *)itemID;

@end

NS_ASSUME_NONNULL_END

