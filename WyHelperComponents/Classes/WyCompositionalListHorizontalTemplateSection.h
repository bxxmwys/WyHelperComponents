//
//  WyCompositionalListHorizontalTemplateSection.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListBaseSection.h"

NS_ASSUME_NONNULL_BEGIN

/// 一个可复用、可二次继承的“水平滚动 Section 模板”：
/// - 开发者可通过子类覆写 cellClass / configure 等方法
/// - 也可以通过不同的 init 参数复用同一个模板类
@interface WyCompositionalListHorizontalTemplateSection : WyCompositionalListBaseSection

/// item 的绝对尺寸（默认：98 x 100）
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;

/// section 内左右边距（默认：leading/trailing = 16）
@property (nonatomic, assign) CGFloat horizontalInset;

/// group 之间的间距（默认：10）
@property (nonatomic, assign) CGFloat interGroupSpacing;

/// 滚动方式（默认：GroupPaging）
@property (nonatomic, assign) UICollectionLayoutSectionOrthogonalScrollingBehavior scrollingBehavior;

- (instancetype)initWithViewModel:(id<WyCompositionalListSectionViewModel>)viewModel NS_DESIGNATED_INITIALIZER;

/// 子类可覆写：cell class 与复用标识
- (Class)cellClass;
- (NSString *)cellReuseIdentifier;

/// 子类可覆写：配置 cell 的展示
- (void)configureCell:(UICollectionViewCell *)cell itemID:(id<NSCopying>)itemID indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

