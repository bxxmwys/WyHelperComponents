//
//  WyCompositionalListDemoHorizontalBaseSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoHorizontalBaseSection.h"

#import "WyCollectionReusableView.h"

@implementation WyCompositionalListDemoHorizontalBaseSection

- (instancetype)initWithViewModel:(id<WyCompositionalListSectionViewModel>)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        _headerHeight = 40.0;
        _footerHeight = 0.0;
    }
    return self;
}

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    [super registerViewsInCollectionView:collectionView];
    [collectionView registerClass:WyCollectionReusableView.class
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)];
    [collectionView registerClass:WyCollectionReusableView.class
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:NSStringFromClass(WyCollectionReusableView.class)];
}

- (NSArray<NSCollectionLayoutBoundarySupplementaryItem *> *)boundarySupplementaryItemsWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSMutableArray<NSCollectionLayoutBoundarySupplementaryItem *> *items = [NSMutableArray array];

    if (self.headerHeight > 0) {
        NSCollectionLayoutSize *size =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.headerHeight]];
        NSCollectionLayoutBoundarySupplementaryItem *header =
        [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                                 elementKind:UICollectionElementKindSectionHeader
                                                                                   alignment:NSRectAlignmentTop];
        [items addObject:header];
    }

    if (self.footerHeight > 0) {
        NSCollectionLayoutSize *size =
        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:self.footerHeight]];
        NSCollectionLayoutBoundarySupplementaryItem *footer =
        [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:size
                                                                                 elementKind:UICollectionElementKindSectionFooter
                                                                                   alignment:NSRectAlignmentBottom];
        [items addObject:footer];
    }

    return items;
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
    if ([self.viewModel respondsToSelector:@selector(headerTitle)] &&
        [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        title = [(id)self.viewModel headerTitle];
    }
    if ([self.viewModel respondsToSelector:@selector(footerTitle)] &&
        [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        title = [(id)self.viewModel footerTitle];
    }
    if (title.length == 0) {
        title = [NSString stringWithFormat:@"%@", self.sectionID];
    }
    view.titleLabel.text = title;

    return view;
}

@end

