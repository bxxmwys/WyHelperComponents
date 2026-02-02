//
//  WyCompositionalListHorizontalTemplateSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListHorizontalTemplateSection.h"

@implementation WyCompositionalListHorizontalTemplateSection

- (instancetype)initWithViewModel:(id<WyCompositionalListSectionViewModel>)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        _itemWidth = 98.0;
        _itemHeight = 100.0;
        _horizontalInset = 16.0;
        _interGroupSpacing = 10.0;
        _scrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;
    }
    return self;
}

- (Class)cellClass {
    return UICollectionViewCell.class;
}

- (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self cellClass]);
}

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self cellClass] forCellWithReuseIdentifier:[self cellReuseIdentifier]];
}

- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID {
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:[self cellReuseIdentifier]
                                              forIndexPath:indexPath];
    [self configureCell:cell itemID:itemID indexPath:indexPath];
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell itemID:(id<NSCopying>)itemID indexPath:(NSIndexPath *)indexPath {
    // 默认不做任何配置；由子类覆写
}

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSCollectionLayoutSize *itemSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:self.itemWidth]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.itemHeight]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];

    NSCollectionLayoutSize *groupSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:self.itemWidth]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.itemHeight]];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:1];

    return [NSCollectionLayoutSection sectionWithGroup:group];
}

- (NSDirectionalEdgeInsets)sectionContentInsets {
    return NSDirectionalEdgeInsetsMake(0, self.horizontalInset, 0, self.horizontalInset);
}

- (CGFloat)sectionInterGroupSpacing {
    return self.interGroupSpacing;
}

- (UICollectionLayoutSectionOrthogonalScrollingBehavior)orthogonalScrollingBehavior {
    return self.scrollingBehavior;
}

@end

