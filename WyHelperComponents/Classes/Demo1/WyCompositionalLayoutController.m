//
//  WyCompositionalLayoutController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/6.
//

#import "WyCompositionalLayoutController.h"
#import "WyBackgroundReusableView.h"
#import "WyCollectionReusableView.h"
#import "WyCollectionViewCell.h"

typedef UICollectionViewDiffableDataSource<NSString *, NSString *> VERDataSource;
typedef NSDiffableDataSourceSnapshot<NSString *, NSString *> VERDiffableSnapshot;

static NSString *const kWyRankSection = @"WyRankSection";
static NSString *const kWyVerSection = @"WyVerticalSection";
static NSString *const kWyHorSection = @"WyHorizontalSection";

@interface WyCompositionalLayoutController ()<UICollectionViewDelegate>

// 主视图
@property (nonatomic, strong) UICollectionView *listView;
// listview 数据绑定
@property (nonatomic, strong) VERDataSource *dataSource;
// listview 数据绑定
@property (nonatomic, strong) VERDiffableSnapshot *dataSnapshot;

@end

@implementation WyCompositionalLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 配置视图
    [self setupView];
    // 配置单元类型
    [self configureDataSource];
    // 伪造数据
    [self reloadListViewData];
}

- (void)setupView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)reloadListViewData {
    
    NSArray *sections = @[kWyRankSection, kWyVerSection, kWyHorSection];
    
    VERDiffableSnapshot *snapshot = [[VERDiffableSnapshot alloc] init];
    [snapshot appendSectionsWithIdentifiers:sections];
    
    for (NSString *identifier in sections) {
        NSInteger rand = arc4random()%6 + 6;
        NSMutableArray *items = [NSMutableArray array];
        for (int i=0; i<=rand; i++) {
            [items addObject:[NSString stringWithFormat:@"%@-%d", identifier, i]];
        }
        [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:identifier];
    }
    
    // 记录一个，用来更新数据
    self.dataSnapshot = snapshot;
    // 应用快照
    if (@available(iOS 16.0, *)) {
        if (@available(iOS 17.0, *)) {
            [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
        } else {
            // Fallback on earlier versions
            [self.dataSource applySnapshotUsingReloadData:snapshot];
        }
    } else {
        [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
    }
}

#pragma mark - Section 样式

- (NSCollectionLayoutSection *)sectionForRankArray {
    // 1. 创建单元格的布局项 (Item)
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:
                                    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:213]
                                                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]];  // 设定单元格的高度为 100

    // 2. 创建竖向排列的 Group，每列最多 3 行
    NSCollectionLayoutGroup *verticalGroup = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:
                                              [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:213]
                                                                             heightDimension:[NSCollectionLayoutDimension absoluteDimension:307]]
                                                                                          subitem:item count:3];
    // 上下cell间距
    verticalGroup.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:3.5];
    


    // 4. 创建水平滚动的 Group，每一行包含多个竖向排列的列
    NSCollectionLayoutGroup *horizontalGroup = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
                                                [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:213]
                                                                               heightDimension:[NSCollectionLayoutDimension estimatedDimension:330]]
                                                                                              subitem:verticalGroup count:1];
    // 6. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:horizontalGroup];
    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 使其支持水平滚动
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    section.interGroupSpacing = 10;
    
    return section;
}

- (NSCollectionLayoutSection *)sectionForVertical {
    // 1. 创建单元格的布局项 (Item)
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:
                                    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.5]
                                                                   heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]];  // 设定单元格的高度为 100

    // 2. 创建竖向排列的 Group，每列最多 3 行
    NSCollectionLayoutGroup *horizontalGroup = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
                                              [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                             heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]
                                                                                          subitem:item count:3];
    // 上下cell间距
    horizontalGroup.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];
    


    // 4. 创建水平滚动的 Group，每一行包含多个竖向排列的列
    NSCollectionLayoutGroup *verticalGroup = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:
                                               [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                              heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]
                                                                                           subitem:horizontalGroup count:1];
                                                                                              
    // 6. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:verticalGroup];
//    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 使其支持水平滚动
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    section.interGroupSpacing = 10;
    
    return section;
}

- (NSCollectionLayoutSection *)sectionForHorizontal {
    // 1. 创建单元格的布局项 (Item)
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:
                                    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.25]
                                                                   heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.0]]];  // 设定单元格的高度为 100
    
    // 2. 创建水平滚动的 Group，每一行包含多个竖向排列的列
    NSCollectionLayoutGroup *horizontalGroup = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
                                                [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.25]
                                                                               heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]
                                                                                              subitem:item count:1];
    // 3. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:horizontalGroup];
    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 使其支持水平滚动
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    section.interGroupSpacing = 10;
    
    return section;
}


#pragma mark - UICollectionViewDiffableDataSource

- (void)configureDataSource {
    [self setupDiffableDataSource];
    
    @weakify(self)
    [self.dataSource setSupplementaryViewProvider:^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            NSString *sectionIdentify = [self.dataSnapshot.sectionIdentifiers objectAtIndex:indexPath.section];
            if (sectionIdentify) {
                header.titleLabel.text = [NSString stringWithFormat:@"%@-Header", sectionIdentify];
            }
            return header;
        } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            NSString *sectionIdentify = [self.dataSnapshot.sectionIdentifiers objectAtIndex:indexPath.section];
            if (sectionIdentify) {
                header.titleLabel.text = [NSString stringWithFormat:@"%@-Footer", sectionIdentify];
            }
            return header;
        } else if ([elementKind isEqualToString:kVEarnRewardV21ElementKindHeader]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.titleLabel.text = @"CollectionView-Header";
            return header;
        } else if ([elementKind isEqualToString:kVEarnRewardV21ElementKindFooter]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.titleLabel.text = @"CollectionView-Footer";
            return header;
        }
        return nil;
    }];
}

- (void)setupDiffableDataSource {
    if (@available(iOS 14.0, *)) {
        
        UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[WyCollectionViewCell class] configurationHandler:^(__kindof WyCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            cell.titleLabel.text = item;
        }];
        
        self.dataSource = [[VERDataSource alloc] initWithCollectionView:self.listView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            return [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:item];
        }];
    }
}

- (void)setupFallbackDataSourceForiOS13 {
    // 兼容iOS 13的实现（手动管理数据源）
    [self.listView registerClass:[WyCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class])];
//    [self.listView registerClass:[VEarnRewardBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardBannerCell class])];
//    [self.listView registerClass:[VEarnRewardTaskCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardTaskCell class])];
//    [self.listView registerClass:[VEarnRewardAppListCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardAppListCell class])];
//    [self.listView registerClass:[VEarnRewardLineCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardLineCell class])];
//    [self.listView registerClass:[VEarnRewardAdvertCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardAdvertCell class])];
//    [self.listView registerClass:[VEarnRewardWatchShortsCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardWatchShortsCell class])];
    
    self.dataSource = [[VERDataSource alloc] initWithCollectionView:self.listView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull itemIdentifier) {
        WyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class]) forIndexPath:indexPath];
        cell.titleLabel.text = itemIdentifier;
        return cell;
    }];
}

- (UICollectionViewCompositionalLayout *)generateLayout {
    @weakify(self)
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment> _Nonnull layoutEnvironment) {
        @strongify(self)
        // 获取当前 section 的标识符
        NSString *sectionIdentifier = [self.dataSource snapshot].sectionIdentifiers[sectionIndex];
        if ([sectionIdentifier isEqualToString:kWyRankSection]) {
            return [self sectionForRankArray];
        } else if ([sectionIdentifier isEqualToString:kWyVerSection]) {
            return [self sectionForVertical];
        } else if ([sectionIdentifier isEqualToString:kWyHorSection]) {
            return [self sectionForHorizontal];
        }
        return nil;
    }];
    
    [layout registerClass:WyBackgroundReusableView.class forDecorationViewOfKind:@"background"];
    
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:kVEarnRewardV21HeaderHeight]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:kVEarnRewardV21ElementKindHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;
    header.zIndex = -1;
    
    NSCollectionLayoutSize *footerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:kVEarnRewardV21FooterHeight]];
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:footerSize elementKind:kVEarnRewardV21ElementKindFooter alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;
    footer.zIndex = -1;
    
    UICollectionViewCompositionalLayoutConfiguration *config = UICollectionViewCompositionalLayoutConfiguration.new;
    config.interSectionSpacing = (12);
    config.boundarySupplementaryItems = @[header, footer];
    
    layout.configuration = config;
    
    return layout;
}

- (UICollectionView *)listView {
    if (!_listView) {
        _listView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[self generateLayout]];
        [_listView registerClass:WyCollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class])];
        [_listView registerClass:WyCollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class])];
        [_listView registerClass:WyCollectionReusableView.class forSupplementaryViewOfKind:kVEarnRewardV21ElementKindHeader withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class])];
        [_listView registerClass:WyCollectionReusableView.class forSupplementaryViewOfKind:kVEarnRewardV21ElementKindFooter withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class])];
        _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _listView.backgroundColor = UIColor.clearColor;
        _listView.delegate = self;
        [self.view addSubview:_listView];
    }
    return _listView;
}
@end
