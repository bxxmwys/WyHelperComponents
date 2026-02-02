//
//  WyCompositionalListBaseSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListBaseSection.h"

@implementation WyCompositionalListBaseSection

- (instancetype)initWithViewModel:(id<WyCompositionalListSectionViewModel>)viewModel {
    self = [super init];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (NSString *)sectionID {
    return self.viewModel.sectionID;
}

- (NSArray<id<NSCopying>> *)itemIDs {
    return self.viewModel.itemIDs;
}

- (void)registerViewsInCollectionView:(UICollectionView *)collectionView {
    // 默认不做任何注册；由子类实现
}

- (UICollectionViewCell *)cellForCollectionView:(UICollectionView *)collectionView
                                     indexPath:(NSIndexPath *)indexPath
                                        itemID:(id<NSCopying>)itemID {
    NSAssert(NO, @"%@ 需要重写 %@ 来返回 cell", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return [UICollectionViewCell new];
}

- (NSCollectionLayoutSection *)layoutSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    NSAssert(NO, @"%@ 需要重写 %@ 来返回 NSCollectionLayoutSection", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // 返回一个空 section，避免 release 环境崩溃导致白屏（但仍建议子类实现）
    NSCollectionLayoutSize *itemSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:0.1]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    NSCollectionLayoutSize *groupSize =
    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:0.1]];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:groupSize subitems:@[item]];
    return [NSCollectionLayoutSection sectionWithGroup:group];
}

- (BOOL)needsInvalidateLayoutAfterApply {
    return NO;
}

@end

