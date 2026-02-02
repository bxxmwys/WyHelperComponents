//
//  WyCompositionalListDemoGridSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoGridSection.h"

#import "WyCollectionReusableView.h"
#import "WyCollectionViewCell.h"

@implementation WyCompositionalListDemoGridSection

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:WyCollectionViewCell.class
       forCellWithReuseIdentifier:NSStringFromClass(WyCollectionViewCell.class)];
    [collectionView registerClass:WyCollectionReusableView.class
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)];
}

- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID {
    WyCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(WyCollectionViewCell.class)
                                              forIndexPath:indexPath];
    cell.backgroundColor = UIColor.systemIndigoColor;
    cell.titleLabel.textColor = UIColor.whiteColor;
    cell.titleLabel.text = (NSString *)itemID;
    return cell;
}

- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSCollectionLayoutSize *size =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:40]];
    NSCollectionLayoutBoundarySupplementaryItem *header =
    [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                             elementKind:UICollectionElementKindSectionHeader
                                                                               alignment:NSRectAlignmentTop];
    return @[header];
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
    if ([self.viewModel respondsToSelector:@selector(headerTitle)]) {
        title = [(id)self.viewModel headerTitle];
    }
    if (title.length == 0) {
        title = [NSString stringWithFormat:@"%@", self.sectionID];
    }
    view.titleLabel.text = title;
    return view;
}

- (NSDirectionalEdgeInsets)sectionContentInsets {
    return NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
}

- (CGFloat)sectionInterGroupSpacing {
    return 10.0;
}

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSCollectionLayoutItem *item =
    [NSCollectionLayoutItem itemWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.33]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]];

    NSCollectionLayoutGroup *group =
    [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
     [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]
                                             subitem:item
                                               count:3];
    group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];

    return [NSCollectionLayoutSection sectionWithGroup:group];
}

@end

