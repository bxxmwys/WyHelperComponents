//
//  WyCompositionalListSectionViewModel.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Section 数据承载（建议由业务 VM 持有）：
/// - Section 只负责布局/视图绑定
/// - 数据与业务状态放在 VM，便于复用与测试
@protocol WyCompositionalListSectionViewModel <NSObject>

@property (nonatomic, copy, readonly) NSString *sectionID;
@property (nonatomic, copy, readonly) NSArray<id<NSCopying>> *itemIDs;

@optional
@property (nonatomic, copy, readonly, nullable) NSString *headerTitle;
@property (nonatomic, copy, readonly, nullable) NSString *footerTitle;

@end

NS_ASSUME_NONNULL_END

