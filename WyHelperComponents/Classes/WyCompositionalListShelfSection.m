//
//  WyCompositionalListShelfSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import "WyCompositionalListShelfSection.h"

#import "WyCollectionReusableView.h"

@interface WyCompositionalListShelfSection ()
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, strong) id<WyCompositionalListSectionDataProvider> dataProvider;
@property (nonatomic, strong) WyCompositionalListShelfConfiguration *configuration;
@end

@implementation WyCompositionalListShelfSection

- (instancetype)initWithSectionID:(NSString *)sectionID
                     dataProvider:(id<WyCompositionalListSectionDataProvider>)dataProvider
                    configuration:(WyCompositionalListShelfConfiguration *)configuration {
    self = [super init];
    if (self) {
        _sectionID = [sectionID copy];
        _dataProvider = dataProvider;
        _configuration = configuration;
    }
    return self;
}

- (NSArray<id<NSCopying>> *)itemIDs {
    return [self.dataProvider itemIDsForSectionID:self.sectionID] ?: @[];
}

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    Class cellClass = self.configuration.cellClass ?: UICollectionViewCell.class;
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];

    // header/footer：允许自定义 kind 与 viewClass
    if (self.configuration.headerHeight > 0) {
        Class headerClass = self.configuration.headerViewClass ?: WyCollectionReusableView.class;
        NSString *kind = self.configuration.headerElementKind ?: UICollectionElementKindSectionHeader;
        [collectionView registerClass:headerClass
           forSupplementaryViewOfKind:kind
                  withReuseIdentifier:NSStringFromClass(headerClass)];
    }
    if (self.configuration.footerHeight > 0) {
        Class footerClass = self.configuration.footerViewClass ?: WyCollectionReusableView.class;
        NSString *kind = self.configuration.footerElementKind ?: UICollectionElementKindSectionFooter;
        [collectionView registerClass:footerClass
           forSupplementaryViewOfKind:kind
                  withReuseIdentifier:NSStringFromClass(footerClass)];
    }
}

- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID {
    Class cellClass = self.configuration.cellClass ?: UICollectionViewCell.class;
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass)
                                              forIndexPath:indexPath];
    if (self.configuration.configureCell) {
        self.configuration.configureCell(cell, itemID, indexPath);
    }
    return cell;
}

- (UICollectionReusableView *)supplementaryViewForCollectionView:(UICollectionView *)collectionView
                                                            kind:(NSString *)kind
                                                       indexPath:(NSIndexPath *)indexPath {
    BOOL isHeader = [kind isEqualToString:(self.configuration.headerElementKind ?: UICollectionElementKindSectionHeader)];
    BOOL isFooter = [kind isEqualToString:(self.configuration.footerElementKind ?: UICollectionElementKindSectionFooter)];

    Class viewClass = nil;
    if (isHeader) { viewClass = self.configuration.headerViewClass ?: WyCollectionReusableView.class; }
    else if (isFooter) { viewClass = self.configuration.footerViewClass ?: WyCollectionReusableView.class; }
    else { viewClass = WyCollectionReusableView.class; }

    UICollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:NSStringFromClass(viewClass)
                                              forIndexPath:indexPath];
    view.backgroundColor = UIColor.systemGray6Color;

    NSString *title = nil;
    if (isHeader &&
        [self.dataProvider respondsToSelector:@selector(headerTitleForSectionID:)]) {
        title = [self.dataProvider headerTitleForSectionID:self.sectionID];
    }
    if (isFooter &&
        [self.dataProvider respondsToSelector:@selector(footerTitleForSectionID:)]) {
        title = [self.dataProvider footerTitleForSectionID:self.sectionID];
    }
    if (title.length == 0) {
        title = self.sectionID;
    }

    // 默认：若是 WyCollectionReusableView（或兼容 titleLabel），就写标题
    if ([view respondsToSelector:NSSelectorFromString(@"titleLabel")]) {
        UILabel *label = [view valueForKey:@"titleLabel"];
        if ([label isKindOfClass:UILabel.class]) {
            label.text = title;
        }
    }

    // 业务自定义配置入口
    if (isHeader && self.configuration.configureHeaderView) {
        self.configuration.configureHeaderView(view, self.sectionID);
    } else if (isFooter && self.configuration.configureFooterView) {
        self.configuration.configureFooterView(view, self.sectionID);
    }

    return view;
}

#pragma mark - Optional layout configs

- (NSDirectionalEdgeInsets)sectionContentInsets { return self.configuration.contentInsets; }
- (CGFloat)sectionInterGroupSpacing { return self.configuration.interGroupSpacing; }
- (UICollectionLayoutSectionOrthogonalScrollingBehavior)orthogonalScrollingBehavior { return self.configuration.orthogonalScrollingBehavior; }

- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSMutableArray<NSCollectionLayoutBoundarySupplementaryItem *> *items = [NSMutableArray array];

    if (self.configuration.headerHeight > 0) {
        NSCollectionLayoutSize *size =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.configuration.headerHeight]];
        NSCollectionLayoutBoundarySupplementaryItem *header =
        [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                                 elementKind:(self.configuration.headerElementKind ?: UICollectionElementKindSectionHeader)
                                                                                   alignment:NSRectAlignmentTop];
        [items addObject:header];
    }

    if (self.configuration.footerHeight > 0) {
        NSCollectionLayoutSize *size =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.configuration.footerHeight]];
        NSCollectionLayoutBoundarySupplementaryItem *footer =
        [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                                 elementKind:(self.configuration.footerElementKind ?: UICollectionElementKindSectionFooter)
                                                                                   alignment:NSRectAlignmentBottom];
        [items addObject:footer];
    }

    return items;
}

- (BOOL)needsInvalidateLayoutAfterApply {
    return (self.configuration.layoutStyle == WyCompositionalListShelfLayoutStyleWaterfall);
}

#pragma mark - Layout

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // 最高优先级：完全自定义 layout 构建（适用于 estimated / 复杂混排）
    if (self.configuration.layoutSectionBuilder) {
        NSCollectionLayoutSection *s = self.configuration.layoutSectionBuilder(environment);
        if (s) { return s; }
    }

    switch (self.configuration.layoutStyle) {
        case WyCompositionalListShelfLayoutStyleRankArray:
            return [self wy_makeRankArraySection];
        case WyCompositionalListShelfLayoutStyleHorizontal:
            return [self wy_makeHorizontalSection];
        case WyCompositionalListShelfLayoutStyleGrid:
            return [self wy_makeGridSectionWithEnvironment:environment];
        case WyCompositionalListShelfLayoutStyleWaterfall:
            return [self wy_makeWaterfallSectionWithEnvironment:environment];
    }
}

- (NSCollectionLayoutSection *)wy_makeRankArraySection {
    CGSize itemSize = self.configuration.itemSize;
    NSCollectionLayoutDimension *itemW = self.configuration.itemWidthDimension ?: [NSCollectionLayoutDimension absoluteDimension:itemSize.width];
    NSCollectionLayoutDimension *itemH = self.configuration.itemHeightDimension ?: [NSCollectionLayoutDimension absoluteDimension:itemSize.height];
    NSCollectionLayoutDimension *groupW = self.configuration.groupWidthDimension ?: itemW;
    NSCollectionLayoutDimension *groupH = self.configuration.groupHeightDimension ?: [NSCollectionLayoutDimension absoluteDimension:self.configuration.rankArrayGroupHeight];
    NSCollectionLayoutItem *item =
    [NSCollectionLayoutItem itemWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:itemW heightDimension:itemH]];

    NSCollectionLayoutGroup *verticalGroup =
    [NSCollectionLayoutGroup verticalGroupWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:groupW heightDimension:groupH]
                                             subitem:item
                                               count:3];
    verticalGroup.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:self.configuration.interItemSpacing];
    return [NSCollectionLayoutSection sectionWithGroup:verticalGroup];
}

- (NSCollectionLayoutSection *)wy_makeHorizontalSection {
    CGSize itemSize = self.configuration.itemSize;
    NSCollectionLayoutDimension *itemW = self.configuration.itemWidthDimension ?: [NSCollectionLayoutDimension absoluteDimension:itemSize.width];
    NSCollectionLayoutDimension *itemH = self.configuration.itemHeightDimension ?: [NSCollectionLayoutDimension absoluteDimension:itemSize.height];
    NSCollectionLayoutDimension *groupW = self.configuration.groupWidthDimension ?: itemW;
    NSCollectionLayoutDimension *groupH = self.configuration.groupHeightDimension ?: itemH;
    NSCollectionLayoutItem *item =
    [NSCollectionLayoutItem itemWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:itemW heightDimension:itemH]];

    NSCollectionLayoutGroup *group =
    [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:groupW heightDimension:groupH]
                                             subitem:item
                                               count:1];
    return [NSCollectionLayoutSection sectionWithGroup:group];
}

- (NSCollectionLayoutSection *)wy_makeGridSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSInteger columns = MAX(self.configuration.numberOfColumns, 1);
    CGFloat height = MAX(self.configuration.itemSize.height, 1);
    NSCollectionLayoutDimension *itemH = self.configuration.itemHeightDimension ?: [NSCollectionLayoutDimension absoluteDimension:height];

    NSCollectionLayoutItem *item =
    [NSCollectionLayoutItem itemWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0 / (CGFloat)columns]
                                    heightDimension:itemH]];

    NSCollectionLayoutGroup *group =
    [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                    heightDimension:(self.configuration.groupHeightDimension ?: itemH)]
                                             subitem:item
                                               count:columns];
    group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:self.configuration.interItemSpacing];
    return [NSCollectionLayoutSection sectionWithGroup:group];
}

- (NSCollectionLayoutSection *)wy_makeWaterfallSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSDirectionalEdgeInsets edgeInsets = self.configuration.contentInsets;
    NSInteger numberOfColumns = MAX(self.configuration.numberOfColumns, 1);
    CGFloat space = self.configuration.interItemSpacing;

    CGFloat contentWidth = environment.container.effectiveContentSize.width;
    CGFloat availableWidth = contentWidth - edgeInsets.leading - edgeInsets.trailing;
    CGFloat itemWidth = (availableWidth - (CGFloat)(numberOfColumns - 1) * space) / (CGFloat)numberOfColumns;

    NSArray<id<NSCopying>> *itemIDs = [self itemIDs];
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:numberOfColumns];
    for (NSInteger i = 0; i < numberOfColumns; i++) {
        [columnHeights addObject:@(edgeInsets.top)];
    }

    NSMutableArray<NSValue *> *frames = [NSMutableArray arrayWithCapacity:itemIDs.count];
    CGFloat maxHeight = 0;

    for (id<NSCopying> itemID in itemIDs) {
        NSInteger targetColumn = 0;
        for (NSInteger c = 0; c < numberOfColumns; c++) {
            if (columnHeights[c].doubleValue < columnHeights[targetColumn].doubleValue) {
                targetColumn = c;
            }
        }

        CGFloat itemHeight = 0;
        if ([self.dataProvider respondsToSelector:@selector(heightForItemID:sectionID:)]) {
            itemHeight = [self.dataProvider heightForItemID:itemID sectionID:self.sectionID];
        }
        if (itemHeight <= 0) { itemHeight = 120; }

        CGFloat x = edgeInsets.leading + (itemWidth + space) * (CGFloat)targetColumn;
        CGFloat y = columnHeights[targetColumn].doubleValue;
        CGFloat spacingY = (y == edgeInsets.top) ? 0 : self.configuration.interGroupSpacing;

        CGRect frame = CGRectMake(x, y + spacingY, itemWidth, itemHeight);
        [frames addObject:[NSValue valueWithCGRect:frame]];

        CGFloat newHeight = y + spacingY + itemHeight;
        columnHeights[targetColumn] = @(newHeight);
        maxHeight = MAX(maxHeight, newHeight);
    }

    CGFloat totalHeight = MAX(maxHeight + edgeInsets.bottom, 0.1);

    NSCollectionLayoutSize *groupSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:totalHeight]];

    NSCollectionLayoutGroup *group =
    [NSCollectionLayoutGroup customGroupWithLayoutSize:groupSize
                                         itemProvider:^NSArray<NSCollectionLayoutGroupCustomItem *> * _Nonnull(id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        NSMutableArray<NSCollectionLayoutGroupCustomItem *> *items = [NSMutableArray arrayWithCapacity:frames.count];
        for (NSValue *value in frames) {
            [items addObject:[NSCollectionLayoutGroupCustomItem customItemWithFrame:value.CGRectValue]];
        }
        return items;
    }];

    return [NSCollectionLayoutSection sectionWithGroup:group];
}

@end

