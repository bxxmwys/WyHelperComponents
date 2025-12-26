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
#import "WaterfallItemModel.h"
#import "WaterfallCell.h"

typedef UICollectionViewDiffableDataSource<NSString *, NSString *> VERDataSource;
typedef NSDiffableDataSourceSnapshot<NSString *, NSString *> VERDiffableSnapshot;

static NSString *const kWyRankSection = @"WyRankSection";
static NSString *const kWyVerSection = @"WyVerticalSection";
static NSString *const kWyHorSection = @"WyHorizontalSection";
static NSString *const kWyWaterfallSection = @"WyWaterfallSection";
static NSString *const kWyTagSection = @"WyTagSection";

@interface WyCompositionalLayoutController ()<UICollectionViewDelegate>

// 主视图
@property (nonatomic, strong) UICollectionView *listView;
// listview 数据绑定
@property (nonatomic, strong) VERDataSource *dataSource;
// listview 数据绑定
@property (nonatomic, strong) VERDiffableSnapshot *dataSnapshot;

@property (nonatomic, strong) NSArray <NSNumber *> *cellHeights;

@property (nonatomic, strong) NSArray<WaterfallItemModel *> *items;

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
    
    NSArray *sections = @[kWyRankSection, kWyHorSection, kWyVerSection, kWyWaterfallSection];//
    
   // Step 1: Prepare data
   NSMutableArray *heights = [NSMutableArray array];
   for (NSInteger i = 0; i < 50; i++) {
       WaterfallItemModel *model = [WaterfallItemModel new];
       model.identifier = [NSString stringWithFormat:@"Item %ld", (long)i+1];
       model.height = arc4random_uniform(100) + 100;
       [heights addObject:model];
   }
   self.items = [NSArray arrayWithArray:heights];

    
    VERDiffableSnapshot *snapshot = [[VERDiffableSnapshot alloc] init];
    [snapshot appendSectionsWithIdentifiers:sections];
    
    NSMutableArray *waterFallCellHeights = [NSMutableArray array];
    
    for (NSString *identifier in sections) {
        NSMutableArray *items = [NSMutableArray array];
        if ([identifier isEqualToString:kWyWaterfallSection]) {
            for (int i=0; i<self.items.count; i++) {
                [items addObject:self.items[i].identifier];
            }
        } else {
            NSInteger rand = arc4random()%6 + 6;
            for (int i=0; i<=rand; i++) {
                NSInteger rand_character = arc4random()%5+1;
                NSString *text = identifier;
                for (int i=0; i<rand_character;i++) {
                    text = [text stringByAppendingString:identifier];
                }
                [items addObject:[NSString stringWithFormat:@"%@-%d", text, i]];
                
                if ([identifier isEqualToString:kWyWaterfallSection]) {
                    NSNumber *number = [NSNumber numberWithInt:(100+arc4random_uniform(200))];
                    [waterFallCellHeights addObject:number];
                }
            }
        }
        
        if (items.count > 0) {
            [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:identifier];
        }
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
    
    // 3.1 section header
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:40]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;
    
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionFooter alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;
    section.boundarySupplementaryItems = @[header, footer];
    
    return section;
}

- (NSCollectionLayoutSection *)sectionForVertical {
    // 1. 创建单元格的布局项 (Item)
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:
                                    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.33]
                                                                   heightDimension:[NSCollectionLayoutDimension estimatedDimension:100]]];  // 设定单元格的高度为 100

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
    
    // 3.1 section header
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:40]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;
    
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionFooter alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;
    section.boundarySupplementaryItems = @[header, footer];
    
    return section;
}

- (NSCollectionLayoutSection *)sectionForHorizontal {
    // 1. 创建单元格的布局项 (Item)
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:
                                    [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                   heightDimension:[NSCollectionLayoutDimension estimatedDimension:100]]];  // 设定单元格的高度为 100
    
    // 2. 创建水平滚动的 Group，每一行包含多个竖向排列的列
    NSCollectionLayoutGroup *horizontalGroup = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
                                                [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:98]
                                                                               heightDimension:[NSCollectionLayoutDimension estimatedDimension:100]]
                                                                                              subitem:item count:1];
    // 3. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:horizontalGroup];
    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 使其支持水平滚动
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    section.interGroupSpacing = 10;
    
    // 3.1 section header
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:40]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;
    
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionFooter alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;
    section.boundarySupplementaryItems = @[header, footer];
    
    return section;
}

- (NSCollectionLayoutSection *)generateWaterfallSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // Swift 对齐：edgeInsets = (top:0, leading:20, bottom:0, trailing:20)
    NSDirectionalEdgeInsets edgeInsets = NSDirectionalEdgeInsetsMake(0, 20, 0, 20);

    // Swift 对齐：2 列、间距 10
    NSInteger numberOfColumns = 2;
    CGFloat space = 10.0;

    // 注意：frames 里已经包含了 edgeInsets，因此 itemWidth 必须从可用宽度中扣掉 leading/trailing；
    // 同时不要再给 group 额外设置 contentInsets（否则会“双重 inset”，很容易触发 compositional self-sizing 反馈环）。
    CGFloat contentWidth = environment.container.effectiveContentSize.width;
    CGFloat availableWidth = contentWidth - edgeInsets.leading - edgeInsets.trailing;
    CGFloat itemWidth = (availableWidth - (CGFloat)(numberOfColumns - 1) * space) / (CGFloat)numberOfColumns;

    // 预计算 frames 与总高度，避免 OC 下 estimated height 触发反复布局的问题
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:numberOfColumns];
    for (NSInteger i = 0; i < numberOfColumns; i++) {
        [columnHeights addObject:@(edgeInsets.top)];
    }

    NSMutableArray<NSValue *> *frames = [NSMutableArray arrayWithCapacity:self.items.count];
    CGFloat maxHeight = 0;

    for (NSInteger i = 0; i < self.items.count; i++) {
        NSInteger targetColumn = 0;
        for (NSInteger c = 0; c < numberOfColumns; c++) {
            if (columnHeights[c].doubleValue < columnHeights[targetColumn].doubleValue) {
                targetColumn = c;
            }
        }

        WaterfallItemModel *model = [self.items objectAtIndex:i];
        CGFloat itemHeight = model.height;

        CGFloat x = edgeInsets.leading + (itemWidth + space) * (CGFloat)targetColumn;
        CGFloat y = columnHeights[targetColumn].doubleValue;
        CGFloat spacingY = (y == edgeInsets.top) ? 0 : space;

        CGRect frame = CGRectMake(x, y + spacingY, itemWidth, itemHeight);
        [frames addObject:[NSValue valueWithCGRect:frame]];

        CGFloat newHeight = y + spacingY + itemHeight;
        columnHeights[targetColumn] = @(newHeight);
        maxHeight = MAX(maxHeight, newHeight);
    }

    NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                       heightDimension:[NSCollectionLayoutDimension estimatedDimension:100]];

    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup customGroupWithLayoutSize:groupSize
                                                                          itemProvider:^NSArray<NSCollectionLayoutGroupCustomItem *> * _Nonnull(id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        NSMutableArray<NSCollectionLayoutGroupCustomItem *> *items = [NSMutableArray arrayWithCapacity:frames.count];
        for (NSValue *value in frames) {
            [items addObject:[NSCollectionLayoutGroupCustomItem customItemWithFrame:value.CGRectValue]];
        }
        return items;
    }];

    return [NSCollectionLayoutSection sectionWithGroup:group];
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
        UICollectionViewCellRegistration *normalRegistration = [UICollectionViewCellRegistration registrationWithCellClass:WyCollectionViewCell.class configurationHandler:^(__kindof WyCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            cell.backgroundColor = UIColor.systemPinkColor;
            cell.titleLabel.text = item;
        }];

        // 瀑布流使用非 self-sizing 的 cell（frame/autoresizing），避免 estimated group height 触发反馈环
        UICollectionViewCellRegistration *waterfallRegistration = [UICollectionViewCellRegistration registrationWithCellClass:WaterfallCell.class configurationHandler:^(__kindof WaterfallCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            [cell configureWithText:item];
        }];
        
        @weakify(self)
        self.dataSource = [[VERDataSource alloc] initWithCollectionView:self.listView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            @strongify(self)
            if (!self) { return nil; }

            // 根据 sectionIdentifier 选择 cell 类型
            NSString *sectionIdentifier = [self.dataSource snapshot].sectionIdentifiers[indexPath.section];
            if ([sectionIdentifier isEqualToString:kWyWaterfallSection]) {
                return [collectionView dequeueConfiguredReusableCellWithRegistration:waterfallRegistration forIndexPath:indexPath item:item];
            }
            return [collectionView dequeueConfiguredReusableCellWithRegistration:normalRegistration forIndexPath:indexPath item:item];
        }];
    }
}

- (void)setupFallbackDataSourceForiOS13 {
    // 兼容iOS 13的实现（手动管理数据源）
    [self.listView registerClass:[WyCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class])];
    [self.listView registerClass:WaterfallCell.class forCellWithReuseIdentifier:NSStringFromClass(WaterfallCell.class)];
//    [self.listView registerClass:[VEarnRewardBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardBannerCell class])];
//    [self.listView registerClass:[VEarnRewardTaskCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardTaskCell class])];
//    [self.listView registerClass:[VEarnRewardAppListCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardAppListCell class])];
//    [self.listView registerClass:[VEarnRewardLineCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardLineCell class])];
//    [self.listView registerClass:[VEarnRewardAdvertCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardAdvertCell class])];
//    [self.listView registerClass:[VEarnRewardWatchShortsCell class] forCellWithReuseIdentifier:NSStringFromClass([VEarnRewardWatchShortsCell class])];
    
    self.dataSource = [[VERDataSource alloc] initWithCollectionView:self.listView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull itemIdentifier) {
        // iOS 13：根据 sectionIdentifier 选择 cell 类型
        NSString *sectionIdentifier = [self.dataSnapshot.sectionIdentifiers objectAtIndex:indexPath.section];
        if ([sectionIdentifier isEqualToString:kWyWaterfallSection]) {
            WaterfallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(WaterfallCell.class) forIndexPath:indexPath];
            [cell configureWithText:itemIdentifier];
            return cell;
        } else {
            WyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class]) forIndexPath:indexPath];
            cell.titleLabel.text = itemIdentifier;
            return cell;
        }
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
        } else if ([sectionIdentifier isEqualToString:kWyWaterfallSection]) {
            return [self generateWaterfallSectionWithEnvironment:layoutEnvironment];
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
