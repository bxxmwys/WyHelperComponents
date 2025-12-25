//
//  SectionPagingCollectionView.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/3.
//

#import "SectionPagingCollectionView.h"

@interface SectionPagingCollectionView ()

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL debugPagingLog;

@end

@implementation SectionPagingCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.enableSectionPaging = YES;
    self.pagingThreshold = 30.0; // 30像素
    self.currentSection = 0;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.debugPagingLog = YES;
}

#pragma mark - Override UIScrollView Methods

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!self.enableSectionPaging || self.isDragging) {
        [super setContentOffset:contentOffset];
        return;
    }
    [super setContentOffset:contentOffset];
}

#pragma mark - Helper Methods

- (CGFloat)wy_clampContentOffsetY:(CGFloat)y {
    UIEdgeInsets inset = self.adjustedContentInset;
    CGFloat minY = -inset.top;
    CGFloat maxY = self.contentSize.height - self.bounds.size.height + inset.bottom;
    if (maxY < minY) {
        maxY = minY;
    }
    if (y < minY) {
        return minY;
    }
    if (y > maxY) {
        return maxY;
    }
    return y;
}

/// 获取section的起始Y坐标
- (CGFloat)startYForSection:(NSInteger)section {
    if (section < 0) {
        return 0;
    }
    
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
    if (section >= numberOfSections) {
        return self.contentSize.height;
    }
    
    // 如果是第一个section，起始位置为0
    if (section == 0) {
        NSInteger itemCount = [self.dataSource collectionView:self numberOfItemsInSection:0];
        if (itemCount > 0) {
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:firstIndexPath];
            return attributes ? CGRectGetMinY(attributes.frame) : 0;
        }
        return 0;
    }
    
    // 获取上一个section的最后一个item的frame
    NSInteger previousSection = section - 1;
    NSInteger previousItemCount = [self.dataSource collectionView:self numberOfItemsInSection:previousSection];
    
    if (previousItemCount > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:previousItemCount - 1 inSection:previousSection];
        UICollectionViewLayoutAttributes *lastAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:lastIndexPath];
        
        if (lastAttributes) {
            // 当前section的起始位置 = 上一个section的最后一个item的底部
            return CGRectGetMaxY(lastAttributes.frame);
        }
    }
    
    return [self startYForSection:previousSection];
}

/// 获取section的结束Y坐标
- (CGFloat)endYForSection:(NSInteger)section {
    if (section < 0) {
        return 0;
    }
    
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
    if (section >= numberOfSections) {
        return self.contentSize.height;
    }
    
    NSInteger itemCount = [self.dataSource collectionView:self numberOfItemsInSection:section];
    
    if (itemCount == 0) {
        return [self startYForSection:section];
    }
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:lastIndexPath];
    
    return attributes ? CGRectGetMaxY(attributes.frame) : [self startYForSection:section];
}

/// 获取section的高度
- (CGFloat)heightForSection:(NSInteger)section {
    CGFloat startY = [self startYForSection:section];
    CGFloat endY = [self endYForSection:section];
    return endY - startY;
}

/// 根据contentOffset判断当前处于哪个section
- (NSInteger)sectionAtContentOffset:(CGPoint)contentOffset {
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
    
    if (numberOfSections == 0) {
        return 0;
    }
    
    // 如果在第一个section之前，返回第一个section
    CGFloat firstSectionStart = [self startYForSection:0];
    if (contentOffset.y < firstSectionStart) {
        return 0;
    }
    
    // 遍历所有section，找到包含当前offset的section
    for (NSInteger i = 0; i < numberOfSections; i++) {
        CGFloat startY = [self startYForSection:i];
        CGFloat endY = [self endYForSection:i];
        
        // 注意：最后一个section使用 <=，其他section使用 <
        if (i == numberOfSections - 1) {
            if (contentOffset.y >= startY && contentOffset.y <= endY) {
                return i;
            }
        } else {
            if (contentOffset.y >= startY && contentOffset.y < endY) {
                return i;
            }
        }
    }
    
    // 如果超出范围，返回最后一个section
    return numberOfSections - 1;
}

/// 判断是否需要回弹到section边界
- (BOOL)shouldSnapToSectionBoundaryWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!self.enableSectionPaging) {
        return NO;
    }
    
    CGFloat targetY = targetContentOffset->y;
    
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
    if (numberOfSections <= 1) {
        return NO;
    }

    // 以“最终可见区域”(viewport)为准判断是否发生 section 过渡
    UIEdgeInsets inset = self.adjustedContentInset;
    CGFloat viewportTop = targetY + inset.top;
    CGFloat viewportBottom = targetY + self.bounds.size.height - inset.bottom;
    CGFloat viewportHeight = viewportBottom - viewportTop;
    if (viewportHeight <= 0) {
        return NO;
    }

    // 找出所有落在 viewport 内的 section 边界（startYForSection(i), i>=1）
    CGFloat viewportCenter = (viewportTop + viewportBottom) * 0.5;
    NSInteger activeBoundaryIndex = NSNotFound; // 代表 nextSectionIndex
    CGFloat activeBoundaryY = 0;
    CGFloat bestDist = CGFLOAT_MAX;

    for (NSInteger i = 1; i < numberOfSections; i++) {
        CGFloat boundaryY = [self startYForSection:i];
        if (boundaryY > viewportTop && boundaryY < viewportBottom) {
            CGFloat dist = fabs(boundaryY - viewportCenter);
            if (dist < bestDist) {
                bestDist = dist;
                activeBoundaryIndex = i;
                activeBoundaryY = boundaryY;
            }
        }
    }

    // viewport 内没有边界 => 没有 section 过渡，完全平滑滚动
    if (activeBoundaryIndex == NSNotFound) {
        return NO;
    }

    NSInteger nextSection = activeBoundaryIndex;
    NSInteger prevSection = nextSection - 1;
    if (prevSection < 0 || nextSection >= numberOfSections) {
        return NO;
    }

    CGFloat prevStart = [self startYForSection:prevSection];
    CGFloat prevEnd = [self endYForSection:prevSection];
    CGFloat nextStart = activeBoundaryY; // == startYForSection(nextSection)

    // 露出高度：上方露出 prev、下方露出 next
    CGFloat revealPrev = MAX(0, activeBoundaryY - viewportTop);
    CGFloat revealNext = MAX(0, viewportBottom - activeBoundaryY);

    // A点：next 第一个 cell 顶部贴齐 viewportTop => contentOffset.y = nextStart - inset.top
    CGFloat snapA = nextStart - inset.top;
    // B点：prev 最后一个 cell 底部贴齐 viewportBottom => contentOffset.y = prevEnd - (boundsH - inset.bottom)
    CGFloat snapB = prevEnd - (self.bounds.size.height - inset.bottom);

    // 先把 B 点限制在 prevSection 内（如果 prevSection 高度不足一屏，则退化为 prevSection 顶部对齐）
    {
        CGFloat sectionMinY = prevStart - inset.top;
        CGFloat sectionMaxY = prevEnd - (self.bounds.size.height - inset.bottom);
        if (sectionMaxY < sectionMinY) {
            sectionMaxY = sectionMinY;
        }
        if (snapB < sectionMinY) {
            snapB = sectionMinY;
        } else if (snapB > sectionMaxY) {
            snapB = sectionMaxY;
        }
    }

    // 再限制在 scrollView 可滚动范围内
    snapA = [self wy_clampContentOffsetY:snapA];
    snapB = [self wy_clampContentOffsetY:snapB];

    CGFloat threshold = MAX(0, self.pagingThreshold);

    if (self.debugPagingLog) {
        NSLog(@"[SectionPaging] boundary=%ld y=%.1f viewportTop=%.1f bottom=%.1f revealPrev=%.1f revealNext=%.1f snapA=%.1f snapB=%.1f vY=%.2f",
              (long)nextSection, activeBoundaryY, viewportTop, viewportBottom, revealPrev, revealNext, snapA, snapB, velocity.y);
    }

    // 决策（按你确认的规则 + 中间区间的兜底策略）
    if (revealPrev < threshold) {
        // 从 A 点向下拉：露出上一 section 不足 threshold，回弹回 A
        targetContentOffset->y = snapA;
        return YES;
    }
    if (revealNext < threshold) {
        // 从 B 点向上推：露出下一 section 不足 threshold，回弹回 B
        targetContentOffset->y = snapB;
        return YES;
    }

    // 两边露出都 >= threshold：说明边界已经在 viewport 中间区域
    // 兜底：优先跟随 velocity；速度很小时用“哪边更可见”来定
    if (fabs(velocity.y) > 0.01) {
        targetContentOffset->y = (velocity.y > 0) ? snapA : snapB;
        return YES;
    }

    // revealPrev 大 => prev 可见更多 => 吸到 B；否则吸到 A
    targetContentOffset->y = (revealPrev > revealNext) ? snapB : snapA;
    return YES;
}

/// 滚动到指定section的底部对齐列表底部
- (void)scrollToAlignBottomOfSection:(NSInteger)section animated:(BOOL)animated {
    if (section < 0 || section >= [self.dataSource numberOfSectionsInCollectionView:self]) {
        return;
    }
    
    CGFloat sectionEndY = [self endYForSection:section];
    CGFloat targetY = sectionEndY - self.bounds.size.height;
    
    // 确保不会滚动到负数位置
    targetY = MAX(0, targetY);
    
    // 确保不会超出contentSize
    CGFloat maxY = self.contentSize.height - self.bounds.size.height;
    targetY = MIN(targetY, maxY);
    
    [self setContentOffset:CGPointMake(0, targetY) animated:animated];
}

/// 滚动到指定section的顶部对齐列表顶部
- (void)scrollToAlignTopOfSection:(NSInteger)section animated:(BOOL)animated {
    if (section < 0 || section >= [self.dataSource numberOfSectionsInCollectionView:self]) {
        return;
    }
    
    CGFloat sectionStartY = [self startYForSection:section];
    
    [self setContentOffset:CGPointMake(0, sectionStartY) animated:animated];
}

@end

