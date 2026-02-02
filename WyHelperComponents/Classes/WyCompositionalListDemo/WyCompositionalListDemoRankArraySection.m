//
//  WyCompositionalListDemoRankArraySection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoRankArraySection.h"

#import "WyCollectionReusableView.h"
#import "WyCollectionViewCell.h"

@implementation WyCompositionalListDemoRankArraySection

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:WyCollectionViewCell.class
       forCellWithReuseIdentifier:NSStringFromClass(WyCollectionViewCell.class)];
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
    WyCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(WyCollectionViewCell.class)
                                              forIndexPath:indexPath];
    cell.backgroundColor = UIColor.systemPinkColor;
    cell.titleLabel.textColor = UIColor.whiteColor;
    cell.titleLabel.text = (NSString *)itemID;
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
        title = [NSString stringWithFormat:@"%@-%@", self.sectionID, [kind containsString:@"Header"] ? @"Header" : @"Footer"];
    }
    view.titleLabel.text = title;

    return view;
}

- (UICollectionLayoutSectionOrthogonalScrollingBehavior)orthogonalScrollingBehavior {
    return UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;
}

- (NSDirectionalEdgeInsets)sectionContentInsets {
    return NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
}

- (CGFloat)sectionInterGroupSpacing {
    return 10.0;
}

- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSCollectionLayoutSize *headerSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]];
    NSCollectionLayoutBoundarySupplementaryItem *header =
    [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize
                                                                             elementKind:UICollectionElementKindSectionHeader
                                                                               alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;

    NSCollectionLayoutBoundarySupplementaryItem *footer =
    [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize
                                                                             elementKind:UICollectionElementKindSectionFooter
                                                                               alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;

    return @[header, footer];
}

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // 与 WyCompositionalLayoutController 的 sectionForRankArray 对齐
    NSCollectionLayoutItem *item =
    [NSCollectionLayoutItem itemWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:213]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]];

    NSCollectionLayoutGroup *verticalGroup =
    [NSCollectionLayoutGroup verticalGroupWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:213]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:307]]
                                             subitem:item
                                               count:3];
    verticalGroup.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:3.5];

    return [NSCollectionLayoutSection sectionWithGroup:verticalGroup];
}

@end

