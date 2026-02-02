//
//  WyCompositionalListView.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListView.h"

@interface WyCompositionalListView ()<UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<id<WyCompositionalListSection>> *sections;
@property (nonatomic, strong) UICollectionViewDiffableDataSource<NSString *, id<NSCopying>> *dataSource;

@end

@implementation WyCompositionalListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self wy_setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self wy_setupView];
    }
    return self;
}

- (void)wy_setupView {
    self.backgroundColor = UIColor.clearColor;
    self.sections = @[];

    UICollectionViewCompositionalLayout *layout = [self wy_makeLayout];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.delegate = self;
    [self addSubview:_collectionView];

    [self wy_setupDataSource];
}

- (UICollectionViewCompositionalLayout *)wy_makeLayout {
    __weak typeof(self) weakSelf = self;
    UICollectionViewCompositionalLayout *layout =
    [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull environment) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return [WyCompositionalListView wy_emptySection]; }
        id<WyCompositionalListSection> section = [self sectionAtIndex:sectionIndex];
        if (!section) { return [WyCompositionalListView wy_emptySection]; }
        NSCollectionLayoutSection *layoutSection = [section layoutSectionWithEnvironment:environment];
        if (!layoutSection) { layoutSection = [WyCompositionalListView wy_emptySection]; }

        // 统一应用可选配置（header/footer/边距/滚动方式等）
        if ([section respondsToSelector:@selector(sectionContentInsets)]) {
            layoutSection.contentInsets = [section sectionContentInsets];
        }
        if ([section respondsToSelector:@selector(sectionInterGroupSpacing)]) {
            layoutSection.interGroupSpacing = [section sectionInterGroupSpacing];
        }
        if ([section respondsToSelector:@selector(orthogonalScrollingBehavior)]) {
            layoutSection.orthogonalScrollingBehavior = [section orthogonalScrollingBehavior];
        }
        if ([section respondsToSelector:@selector(boundarySupplementaryItemsWithEnvironment:)]) {
            layoutSection.boundarySupplementaryItems = [section boundarySupplementaryItemsWithEnvironment:environment] ?: @[];
        }
        if ([section respondsToSelector:@selector(decorationItemsWithEnvironment:)]) {
            layoutSection.decorationItems = [section decorationItemsWithEnvironment:environment] ?: @[];
        }

        return layoutSection;
    }];
    return layout;
}

+ (NSCollectionLayoutSection *)wy_emptySection {
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

- (void)wy_setupDataSource {
    __weak typeof(self) weakSelf = self;
    self.dataSource =
    [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView
                                                          cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id<NSCopying>  _Nonnull itemIdentifier) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return nil; }
        id<WyCompositionalListSection> section = [self sectionAtIndex:indexPath.section];
        if (!section) { return nil; }
        return [section cellForCollectionView:collectionView
                                    indexPath:indexPath
                                       itemID:itemIdentifier];
    }];

    self.dataSource.supplementaryViewProvider =
    ^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull kind, NSIndexPath * _Nonnull indexPath) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return nil; }
        id<WyCompositionalListSection> section = [self sectionAtIndex:indexPath.section];
        if (!section) { return nil; }
        if ([section respondsToSelector:@selector(supplementaryViewForCollectionView:kind:indexPath:)]) {
            return [section supplementaryViewForCollectionView:collectionView kind:kind indexPath:indexPath];
        }
        return nil;
    };
}

- (nullable id<WyCompositionalListSection>)sectionAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.sections.count) { return nil; }
    return [self.sections objectAtIndex:index];
}

- (void)setSections:(NSArray<id<WyCompositionalListSection>> *)sections animated:(BOOL)animated {
    _sections = [sections copy] ?: @[];

    // 让每个 section 自己完成注册（cell / supplementary）
    for (id<WyCompositionalListSection> section in _sections) {
        [section registerViewsInCollectionView:self.collectionView];
    }

    // 更新 layout（sectionProvider 读取 self.sections，因此直接 invalidate 触发重算即可）
    [self.collectionView.collectionViewLayout invalidateLayout];

    [self reloadSnapshotAnimated:animated];
}

- (void)reloadSnapshotAnimated:(BOOL)animated {
    NSDiffableDataSourceSnapshot<NSString *, id<NSCopying>> *snapshot = [NSDiffableDataSourceSnapshot new];

    NSMutableArray<NSString *> *sectionIDs = [NSMutableArray arrayWithCapacity:self.sections.count];
    for (id<WyCompositionalListSection> section in self.sections) {
        [sectionIDs addObject:section.sectionID ?: @""];
    }
    [snapshot appendSectionsWithIdentifiers:sectionIDs];

    for (id<WyCompositionalListSection> section in self.sections) {
        NSArray<id<NSCopying>> *items = [section itemIDs] ?: @[];
        if (items.count > 0) {
            [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:section.sectionID];
        }
    }

    [self.dataSource applySnapshot:snapshot animatingDifferences:animated];

    // 若某些 section 的布局依赖 itemIDs（customGroup 预计算 frames），apply 后可以选择 invalidate
    BOOL needsInvalidate = NO;
    for (id<WyCompositionalListSection> section in self.sections) {
        if ([section respondsToSelector:@selector(needsInvalidateLayoutAfterApply)] && [section needsInvalidateLayoutAfterApply]) {
            needsInvalidate = YES;
            break;
        }
    }
    if (needsInvalidate) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id itemID = [self.dataSource itemIdentifierForIndexPath:indexPath];
    id<WyCompositionalListSection> section = [self sectionAtIndex:indexPath.section];
    if (!section || !itemID) { return; }
    if ([section respondsToSelector:@selector(didSelectItemID:indexPath:)]) {
        [section didSelectItemID:(id<NSCopying>)itemID indexPath:indexPath];
    }
}

@end

