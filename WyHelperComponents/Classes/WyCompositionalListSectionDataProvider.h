//
//  WyCompositionalListSectionDataProvider.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 一个“页面级”的数据提供者（通常就是同一个 VM）：
/// - 同一个列表里多个书架（Section）的数据由一个 VM 统一管理
/// - Section 只持有 sectionID，通过该 provider 取数据/标题/高度等
@protocol WyCompositionalListSectionDataProvider <NSObject>

/// 返回指定 sectionID 的 itemIDs（需稳定且遵守 NSCopying）
- (NSArray<id<NSCopying>> *)itemIDsForSectionID:(NSString *)sectionID;

@optional
- (nullable NSString *)headerTitleForSectionID:(NSString *)sectionID;
- (nullable NSString *)footerTitleForSectionID:(NSString *)sectionID;

/// 瀑布流/自定义布局可用：返回 item 高度（返回 <=0 则由调用方使用默认值）
- (CGFloat)heightForItemID:(id<NSCopying>)itemID sectionID:(NSString *)sectionID;

@end

NS_ASSUME_NONNULL_END

