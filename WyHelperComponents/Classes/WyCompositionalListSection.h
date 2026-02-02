//
//  WyCompositionalListSection.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Compositional 列表的“Section 模块”协议：
/// - 外层列表组件不做 if/else 分发，不知道具体样式与 cell 类型
/// - 新增/删除某个 Section，只需要在 assembly（一个文件）里增删一行
@protocol WyCompositionalListSection <NSObject>

/// 稳定且唯一的 Section 标识（不要用随机值）
@property (nonatomic, copy, readonly) NSString *sectionID;

/// 当前 Section 的 item 标识集合（元素需稳定且遵守 NSCopying）
- (NSArray<id<NSCopying>> *)itemIDs;

/// 返回该 Section 的 compositional 布局
- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment;

/// 统一在外层 setSections 时调用，Section 自己完成 cell / supplementary 注册
- (void)registerViewsInCollectionView:(UICollectionView *)collectionView;

/// 外层 dataSource 的 cellProvider 直接转发到这里
- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID;

@optional
/// Section 的内容边距（如果实现了，外层会在 layoutSection 上统一应用）
- (NSDirectionalEdgeInsets)sectionContentInsets;

/// Group 与 Group 的间距（如果实现了，外层会在 layoutSection 上统一应用）
- (CGFloat)sectionInterGroupSpacing;

/// Section 的滚动方式（如果实现了，外层会在 layoutSection 上统一应用）
- (UICollectionLayoutSectionOrthogonalScrollingBehavior)orthogonalScrollingBehavior;

/// Section 的 header/footer 等 supplementary layout（如果实现了，外层会在 layoutSection 上统一应用）
- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment;

/// Section 的 decorationItems（如果实现了，外层会在 layoutSection 上统一应用）
- (NSArray<NSCollectionLayoutDecorationItem *> *)decorationItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment;

/// 外层 supplementaryViewProvider 直接转发到这里（kind 由 section 自己识别）
- (nullable UICollectionReusableView *)supplementaryViewForCollectionView:(UICollectionView *)collectionView
                                                                     kind:(NSString *)kind
                                                                indexPath:(NSIndexPath *)indexPath;

/// 点击回调（由外层代理转发）
- (void)didSelectItemID:(id<NSCopying>)itemID indexPath:(NSIndexPath *)indexPath;

/// 若该 Section 的布局依赖数据（customGroup 预计算 frames），可返回 YES 以便外层在 apply 后 invalidateLayout
- (BOOL)needsInvalidateLayoutAfterApply;

@end

NS_ASSUME_NONNULL_END

