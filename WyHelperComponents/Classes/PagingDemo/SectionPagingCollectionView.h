//
//  SectionPagingCollectionView.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SectionPagingCollectionView : UICollectionView

/// 启用section级别的分页效果
@property (nonatomic, assign) BOOL enableSectionPaging;

/// 分页回弹的阈值（像素值），默认30，表示滑动距离小于30像素时会回弹
@property (nonatomic, assign) CGFloat pagingThreshold;

/// 滚动到指定section的底部对齐列表底部
- (void)scrollToAlignBottomOfSection:(NSInteger)section animated:(BOOL)animated;

/// 滚动到指定section的顶部对齐列表顶部
- (void)scrollToAlignTopOfSection:(NSInteger)section animated:(BOOL)animated;

/// 判断是否需要回弹到section边界
- (BOOL)shouldSnapToSectionBoundaryWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

@end

NS_ASSUME_NONNULL_END

