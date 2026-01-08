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
#import <QMUIKit/UIColor+QMUI.h>

typedef UICollectionViewDiffableDataSource<NSString *, NSString *> VERDataSource;
typedef NSDiffableDataSourceSnapshot<NSString *, NSString *> VERDiffableSnapshot;

static NSString *const kWyRankSection = @"WyRankSection";
static NSString *const kWyVerSection = @"WyVerticalSection";
static NSString *const kWyHorSection = @"WyHorizontalSection";
static NSString *const kWyWaterfallSection = @"WyWaterfallSection";
static NSString *const kWyTagSection = @"WyTagSection";
static NSString *const kWyNineGridSection = @"WyNineGridSection";

// 特殊 item 前缀标识（全宽 200 高度）
static NSString *const kWyVerSpecialItemPrefix = @"__wy_ver_special__";

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
    // 配置头尾视图
    [self setupHeaderAndFooter];
    // 伪造数据
    [self reloadListViewData];
}

- (void)setupView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 导航栏右侧添加按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(onTapAdd)];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

#pragma mark - Actions

- (void)onTapAdd {
    // 生成唯一的特殊 item 标识
    NSString *specialItemId = [NSString stringWithFormat:@"%@%lld", kWyVerSpecialItemPrefix, (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    
    // 从当前 snapshot 拿到可变副本
    VERDiffableSnapshot *snapshot = [[self.dataSource snapshot] copy];
    
    // 获取Section的items
    NSArray *itemsInNineGridSection = [snapshot itemIdentifiersInSectionWithIdentifier:kWyNineGridSection];
    
    NSString *findItemIdentifier = nil;
    for (int i=3; i<itemsInNineGridSection.count; i+=3) {
        NSString *item_id = [itemsInNineGridSection objectAtIndex:i];
        if ([item_id hasPrefix:kWyVerSpecialItemPrefix]) {
            i++;
        } else {
            findItemIdentifier = item_id;
            break;
        }
    }
    
    if (findItemIdentifier) {
        // 向 kWyNineGridSection 插入特殊 item
        [snapshot insertItemsWithIdentifiers:@[specialItemId] beforeItemWithIdentifier:findItemIdentifier];
    } else {
        // 向 kWyNineGridSection 追加特殊 item
        [snapshot appendItemsWithIdentifiers:@[specialItemId] intoSectionWithIdentifier:kWyNineGridSection];
    }
    
    // 更新缓存
    self.dataSnapshot = snapshot;
    
    // 应用快照（带动画）
    if (@available(iOS 16.0, *)) {
        if (@available(iOS 17.0, *)) {
            [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
        } else {
            [self.dataSource applySnapshotUsingReloadData:snapshot];
        }
    } else {
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    }
    
    // 刷新布局（因为 customGroup 需要根据新数据重新计算 frames）
    [self.listView.collectionViewLayout invalidateLayout];
}

- (void)reloadListViewData {
    
    NSArray *sections = @[kWyRankSection, kWyHorSection, kWyVerSection, kWyNineGridSection, kWyWaterfallSection];//
    
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
        
//        // 在 kWyVerSection 的索引 3 插入一次特殊 item（全宽 200）
//        if ([identifier isEqualToString:kWyVerSection]) {
//            NSString *specialItemId = [NSString stringWithFormat:@"%@initial_%lld", kWyVerSpecialItemPrefix, (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
//            NSInteger insertIndex = (items.count >= 3) ? 3 : items.count;
//            [items insertObject:specialItemId atIndex:insertIndex];
//        }
        
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
    

    // 3. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:verticalGroup];
    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 按Group分页
    // Section内部inset
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    // Group与Group之间的间距
    section.interGroupSpacing = 10;
    
    // 4 section header
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]];
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

    // 2. 创建水平Group，每行限制3个；
    NSCollectionLayoutGroup *horizontalGroup = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:
                                              [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                             heightDimension:[NSCollectionLayoutDimension estimatedDimension:100]]
                                                                                          subitem:item count:3];
    // cell间距
    horizontalGroup.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];
    
    // group的inset
    horizontalGroup.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    

                                                                                              
    // 3. 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:horizontalGroup];
//    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;  // 使其支持水平滚动
//    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
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

- (NSCollectionLayoutSection *)sectionForVerticalWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // 布局参数
    CGFloat horizontalInset = 16.0;
    CGFloat interItemSpacing = 10.0;
    CGFloat interGroupSpacing = 10.0;
    NSInteger numberOfColumns = 3;
    CGFloat normalItemHeight = 100.0;
    CGFloat specialItemHeight = 200.0;
    
    // 计算可用宽度与普通 item 宽度
    CGFloat contentWidth = environment.container.effectiveContentSize.width;
    CGFloat availableWidth = contentWidth - horizontalInset * 2;
    CGFloat normalItemWidth = (availableWidth - (numberOfColumns - 1) * interItemSpacing) / numberOfColumns;
    
    // 获取当前 kWyVerSection 的所有 itemIdentifiers
    NSArray<NSString *> *itemIdentifiers = [[self.dataSource snapshot] itemIdentifiersInSectionWithIdentifier:kWyNineGridSection];
    
    // 预计算每个 item 的 frame
    NSMutableArray<NSValue *> *frames = [NSMutableArray arrayWithCapacity:itemIdentifiers.count];
    CGFloat currentY = 0;
    NSInteger currentColumnIndex = 0;
    
    for (NSInteger i = 0; i < itemIdentifiers.count; i++) {
        NSString *itemId = itemIdentifiers[i];
        BOOL isSpecial = [itemId hasPrefix:kWyVerSpecialItemPrefix];
        
        if (isSpecial) {
            // 特殊 item：全宽，高度 200
            // 如果当前行有普通 item，先换行
            if (currentColumnIndex > 0) {
                currentY += normalItemHeight + interGroupSpacing;
                currentColumnIndex = 0;
            }
            
            CGRect frame = CGRectMake(0, currentY, contentWidth, specialItemHeight);
            [frames addObject:[NSValue valueWithCGRect:frame]];
            
            currentY += specialItemHeight + interGroupSpacing;
            currentColumnIndex = 0;
        } else {
            // 普通 item：3 列网格
            CGFloat x = horizontalInset + currentColumnIndex * (normalItemWidth + interItemSpacing);
            CGRect frame = CGRectMake(x, currentY, normalItemWidth, normalItemHeight);
            [frames addObject:[NSValue valueWithCGRect:frame]];
            
            currentColumnIndex++;
            if (currentColumnIndex >= numberOfColumns) {
                currentColumnIndex = 0;
                currentY += normalItemHeight + interGroupSpacing;
            }
        }
    }
    
    // 计算总高度（如果最后一行有未满的普通 item，也要计入）
    CGFloat totalHeight = currentY;
    if (currentColumnIndex > 0) {
        totalHeight += normalItemHeight;
    }
    
    // 创建 customGroup
    NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:totalHeight]];
    
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup customGroupWithLayoutSize:groupSize
                                                                          itemProvider:^NSArray<NSCollectionLayoutGroupCustomItem *> * _Nonnull(id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        NSMutableArray<NSCollectionLayoutGroupCustomItem *> *layoutItems = [NSMutableArray arrayWithCapacity:frames.count];
        for (NSValue *value in frames) {
            [layoutItems addObject:[NSCollectionLayoutGroupCustomItem customItemWithFrame:value.CGRectValue]];
        }
        return layoutItems;
    }];
    
    // 创建 Section
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
    
    // section header & footer
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
}

- (void)setupHeaderAndFooter {
    @weakify(self)
    [self.dataSource setSupplementaryViewProvider:^UICollectionReusableView * _Nullable(UICollectionView * _Nonnull collectionView, NSString * _Nonnull elementKind, NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.backgroundColor = [UIColor qmui_randomColor];
            NSString *sectionIdentify = [self.dataSnapshot.sectionIdentifiers objectAtIndex:indexPath.section];
            if (sectionIdentify) {
                header.titleLabel.text = [NSString stringWithFormat:@"%@-Header", sectionIdentify];
            }
            return header;
        } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.backgroundColor = [UIColor qmui_randomColor];
            NSString *sectionIdentify = [self.dataSnapshot.sectionIdentifiers objectAtIndex:indexPath.section];
            if (sectionIdentify) {
                header.titleLabel.text = [NSString stringWithFormat:@"%@-Footer", sectionIdentify];
            }
            return header;
        } else if ([elementKind isEqualToString:kVEarnRewardV21ElementKindHeader]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.titleLabel.text = @"CollectionView-Header";
            header.backgroundColor = [UIColor qmui_randomColor];
            return header;
        } else if ([elementKind isEqualToString:kVEarnRewardV21ElementKindFooter]) {
            WyCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:elementKind withReuseIdentifier:NSStringFromClass([WyCollectionReusableView class]) forIndexPath:indexPath];
            header.titleLabel.text = @"CollectionView-Footer";
            header.backgroundColor = [UIColor qmui_randomColor];
            return header;
        }
        return nil;
    }];
}

- (void)setupDiffableDataSource {
    if (@available(iOS 14.0, *)) {
        // 普通 cell（粉色背景）
        UICollectionViewCellRegistration *normalRegistration = [UICollectionViewCellRegistration registrationWithCellClass:WyCollectionViewCell.class configurationHandler:^(__kindof WyCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            cell.backgroundColor = UIColor.systemPinkColor;
            cell.titleLabel.text = item;
        }];

        // 瀑布流使用非 self-sizing 的 cell（frame/autoresizing），避免 estimated group height 触发反馈环
        UICollectionViewCellRegistration *waterfallRegistration = [UICollectionViewCellRegistration registrationWithCellClass:WaterfallCell.class configurationHandler:^(__kindof WaterfallCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            [cell configureWithText:item];
        }];
        
        // 特殊 item（全宽 200，蓝色背景，不同文案）
        UICollectionViewCellRegistration *specialRegistration = [UICollectionViewCellRegistration registrationWithCellClass:WyCollectionViewCell.class configurationHandler:^(__kindof WyCollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull item) {
            cell.backgroundColor = UIColor.systemBlueColor;
            cell.titleLabel.text = @"特殊全宽 Item (200)";
            cell.titleLabel.textColor = UIColor.whiteColor;
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
            
            // 特殊 item（全宽 200）走蓝色样式
            if ([item hasPrefix:kWyVerSpecialItemPrefix]) {
                return [collectionView dequeueConfiguredReusableCellWithRegistration:specialRegistration forIndexPath:indexPath item:item];
            }
            
            if ([sectionIdentifier isEqualToString:kWyNineGridSection]) {
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
        } else if ([itemIdentifier hasPrefix:kWyVerSpecialItemPrefix]) {
            // 特殊 item（全宽 200）走蓝色样式
            WyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class]) forIndexPath:indexPath];
            cell.backgroundColor = UIColor.systemBlueColor;
            cell.titleLabel.text = @"特殊全宽 Item (200)";
            cell.titleLabel.textColor = UIColor.whiteColor;
            return cell;
        } else {
            WyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WyCollectionViewCell class]) forIndexPath:indexPath];
            cell.backgroundColor = UIColor.systemPinkColor;
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
        // 根据标识判断Section的样式类型，然后根据类型，初始化不同的Section样式；
        if ([sectionIdentifier isEqualToString:kWyRankSection]) {
            return [self sectionForRankArray];
        } else if ([sectionIdentifier isEqualToString:kWyVerSection]) {
            return [self sectionForVertical];
        } else if ([sectionIdentifier isEqualToString:kWyNineGridSection]) {
            return [self sectionForVerticalWithEnvironment:layoutEnvironment];
        } else if ([sectionIdentifier isEqualToString:kWyHorSection]) {
            return [self sectionForHorizontal];
        } else if ([sectionIdentifier isEqualToString:kWyWaterfallSection]) {
            return [self generateWaterfallSectionWithEnvironment:layoutEnvironment];
        }
        return nil;
    }];
    
    // 注册背景的样式
    [layout registerClass:WyBackgroundReusableView.class forDecorationViewOfKind:@"background"];
    
    // 初始化layout的Header
    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:kVEarnRewardV21HeaderHeight]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:kVEarnRewardV21ElementKindHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = NO;
    header.zIndex = -1;
    
    // 初始化layout的Footer
    NSCollectionLayoutSize *footerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0] heightDimension:[NSCollectionLayoutDimension absoluteDimension:kVEarnRewardV21FooterHeight]];
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:footerSize elementKind:kVEarnRewardV21ElementKindFooter alignment:NSRectAlignmentBottom];
    footer.pinToVisibleBounds = NO;
    footer.zIndex = -1;
    
    UICollectionViewCompositionalLayoutConfiguration *config = UICollectionViewCompositionalLayoutConfiguration.new;
    // Section与Section之间的间距
    config.interSectionSpacing = (12);
    // layout整组的header与footer
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
