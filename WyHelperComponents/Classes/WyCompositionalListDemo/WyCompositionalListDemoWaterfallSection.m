//
//  WyCompositionalListDemoWaterfallSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoWaterfallSection.h"

#import "WyCompositionalListDemoWaterfallVM.h"

#import "WaterfallCell.h"
#import "WyCollectionReusableView.h"

@implementation WyCompositionalListDemoWaterfallSection

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:WaterfallCell.class
       forCellWithReuseIdentifier:NSStringFromClass(WaterfallCell.class)];
    [collectionView registerClass:WyCollectionReusableView.class
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)];
    [collectionView registerClass:WyCollectionReusableView.class
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)];
}

- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID {
    WaterfallCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(WaterfallCell.class)
                                              forIndexPath:indexPath];
    [cell configureWithText:(NSString *)itemID];
    return cell;
}

- (UICollectionReusableView *)supplementaryViewForCollectionView:(UICollectionView *)collectionView
                                                            kind:(NSString *)kind
                                                       indexPath:(NSIndexPath *)indexPath {
    WyCollectionReusableView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)
                                              forIndexPath:indexPath];
    view.backgroundColor = UIColor.systemGray6Color;

    NSString *title = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] &&
        [self.viewModel respondsToSelector:@selector(headerTitle)]) {
        title = [(id)self.viewModel headerTitle];
    }
    if ([kind isEqualToString:UICollectionElementKindSectionFooter] &&
        [self.viewModel respondsToSelector:@selector(footerTitle)]) {
        title = [(id)self.viewModel footerTitle];
    }
    if (title.length == 0) {
        title = [NSString stringWithFormat:@"%@", self.sectionID];
    }
    view.titleLabel.text = title;
    return view;
}

- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSCollectionLayoutSize *size =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:40]];
    NSCollectionLayoutBoundarySupplementaryItem *header =
    [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                             elementKind:UICollectionElementKindSectionHeader
                                                                               alignment:NSRectAlignmentTop];
    NSCollectionLayoutBoundarySupplementaryItem *footer =
    [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                             elementKind:UICollectionElementKindSectionFooter
                                                                               alignment:NSRectAlignmentBottom];
    return @[header, footer];
}

- (BOOL)needsInvalidateLayoutAfterApply {
    return YES;
}

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // 与 WyCompositionalLayoutController 的 generateWaterfallSectionWithEnvironment 对齐
    NSDirectionalEdgeInsets edgeInsets = NSDirectionalEdgeInsetsMake(0, 20, 0, 20);
    NSInteger numberOfColumns = 2;
    CGFloat space = 10.0;

    CGFloat contentWidth = environment.container.effectiveContentSize.width;
    CGFloat availableWidth = contentWidth - edgeInsets.leading - edgeInsets.trailing;
    CGFloat itemWidth = (availableWidth - (CGFloat)(numberOfColumns - 1) * space) / (CGFloat)numberOfColumns;

    // 预计算 frames 与总高度（高度从 VM 获取）
    NSArray<NSString *> *itemIDs = (NSArray<NSString *> *)[self itemIDs];
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:numberOfColumns];
    for (NSInteger i = 0; i < numberOfColumns; i++) {
        [columnHeights addObject:@(edgeInsets.top)];
    }

    NSMutableArray<NSValue *> *frames = [NSMutableArray arrayWithCapacity:itemIDs.count];
    CGFloat maxHeight = 0;

    WyCompositionalListDemoWaterfallVM *vm = nil;
    if ([self.viewModel isKindOfClass:WyCompositionalListDemoWaterfallVM.class]) {
        vm = (WyCompositionalListDemoWaterfallVM *)self.viewModel;
    }

    for (NSString *itemID in itemIDs) {
        NSInteger targetColumn = 0;
        for (NSInteger c = 0; c < numberOfColumns; c++) {
            if (columnHeights[c].doubleValue < columnHeights[targetColumn].doubleValue) {
                targetColumn = c;
            }
        }

        CGFloat itemHeight = [vm heightForItemID:itemID];
        if (itemHeight <= 0) { itemHeight = 120; }

        CGFloat x = edgeInsets.leading + (itemWidth + space) * (CGFloat)targetColumn;
        CGFloat y = columnHeights[targetColumn].doubleValue;
        CGFloat spacingY = (y == edgeInsets.top) ? 0 : space;

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

