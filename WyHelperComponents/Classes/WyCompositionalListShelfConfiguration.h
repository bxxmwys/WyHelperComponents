//
//  WyCompositionalListShelfConfiguration.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WyCompositionalListShelfLayoutStyle) {
    /// 复刻：竖向 3 行 group + 横向 paging（类似 sectionForRankArray）
    WyCompositionalListShelfLayoutStyleRankArray = 0,
    /// 水平滚动：单个 item 的横向列表
    WyCompositionalListShelfLayoutStyleHorizontal,
    /// 竖向网格：固定列数（如 3 列）
    WyCompositionalListShelfLayoutStyleGrid,
    /// 瀑布流：固定列数（默认 2 列），高度由 dataProvider 提供
    WyCompositionalListShelfLayoutStyleWaterfall,
};

/// 通用书架配置：尽量用“配置而非 subclass”来表达差异
@interface WyCompositionalListShelfConfiguration : NSObject

@property (nonatomic, assign) WyCompositionalListShelfLayoutStyle layoutStyle;

/// 进阶：允许直接自定义构建 NSCollectionLayoutSection（需要 estimated/group 自适应/复杂混排时用）
/// - 若设置该 block，将优先使用它返回的 layoutSection
@property (nonatomic, copy, nullable) NSCollectionLayoutSection * (^layoutSectionBuilder)(id<NSCollectionLayoutEnvironment> environment);

/// item 尺寸（绝对值）。不同 style 会读取不同字段：
/// - RankArray：itemSize = (213, 100)，groupHeight 可用 groupHeight 覆写
/// - Horizontal：itemSize = (w, h)
/// - Grid：itemHeight 用 itemSize.height，宽度按列数等分
/// - Waterfall：itemWidth 按列数等分，高度由 dataProvider 提供
@property (nonatomic, assign) CGSize itemSize;

/// 进阶：Item/Group 的 layoutSize 维度入口（用于 estimated/self-sizing 等）
/// - 若为 nil，则使用 itemSize/默认策略
@property (nonatomic, strong, nullable) NSCollectionLayoutDimension *itemWidthDimension;
@property (nonatomic, strong, nullable) NSCollectionLayoutDimension *itemHeightDimension;
@property (nonatomic, strong, nullable) NSCollectionLayoutDimension *groupWidthDimension;
@property (nonatomic, strong, nullable) NSCollectionLayoutDimension *groupHeightDimension;

/// RankArray：group 的高度（默认 307，与旧代码对齐）
@property (nonatomic, assign) CGFloat rankArrayGroupHeight;

/// Grid/Waterfall 的列数（默认：Grid=3，Waterfall=2）
@property (nonatomic, assign) NSInteger numberOfColumns;

/// 间距与边距
@property (nonatomic, assign) NSDirectionalEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat interItemSpacing;   // Grid/RankArray 内部 spacing
@property (nonatomic, assign) CGFloat interGroupSpacing;

/// header/footer
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

/// header/footer 自定义入口：
/// - elementKind：默认使用系统 header/footer kind
/// - viewClass：默认使用 WyCollectionReusableView
/// - configure：给业务配置视图的机会（样式多样性）
@property (nonatomic, copy) NSString *headerElementKind;
@property (nonatomic, copy) NSString *footerElementKind;
@property (nonatomic, strong) Class headerViewClass;
@property (nonatomic, strong) Class footerViewClass;
@property (nonatomic, copy, nullable) void (^configureHeaderView)(UICollectionReusableView *view, NSString *sectionID);
@property (nonatomic, copy, nullable) void (^configureFooterView)(UICollectionReusableView *view, NSString *sectionID);

/// 滚动方式（Horizontal/RankArray 常用）
@property (nonatomic, assign) UICollectionLayoutSectionOrthogonalScrollingBehavior orthogonalScrollingBehavior;

/// cell 配置
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, copy) void (^configureCell)(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath);

/// 默认提供一个配置对象（你可以按需修改参数）
+ (instancetype)defaultConfigurationWithStyle:(WyCompositionalListShelfLayoutStyle)style;

@end

NS_ASSUME_NONNULL_END

