//
//  WyCompositionalListView.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <UIKit/UIKit.h>

#import "WyCompositionalListSection.h"

NS_ASSUME_NONNULL_BEGIN

/// 一个独立、解耦的 Compositional 列表容器：
/// - 内部使用 UICollectionViewCompositionalLayout + DiffableDataSource
/// - 通过 section 模块数组驱动（无 if/else 分支）
@interface WyCompositionalListView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, copy, readonly) NSArray<id<WyCompositionalListSection>> *sections;

/// 设置 section 列表（编译期增删 section：只改 assembly 的数组）
- (void)setSections:(NSArray<id<WyCompositionalListSection>> *)sections animated:(BOOL)animated;

/// 重新构建并应用 snapshot（当 section 内部 itemIDs 变化时可调用）
- (void)reloadSnapshotAnimated:(BOOL)animated;

/// 获取对应 index 的 section（越界返回 nil）
- (nullable id<WyCompositionalListSection>)sectionAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

