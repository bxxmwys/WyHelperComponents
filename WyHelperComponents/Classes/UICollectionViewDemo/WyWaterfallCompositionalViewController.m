//
//  WyWaterfallCompositionalViewController.m
//  WyHelperComponents
//
//  Created by Cursor on 2025/12/26.
//

#import "WyWaterfallCompositionalViewController.h"

static NSString *const kWyWaterfallCellReuseId = @"kWyWaterfallCellReuseId";

@interface WyWaterfallCompositionalViewController ()

@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) UICollectionViewDiffableDataSource<NSNumber *, NSString *> *dataSource;

/// item 标识符列表：@"Test 0" ... @"Test 70"
@property (nonatomic, copy) NSArray<NSString *> *items;

/// 用于稳定布局的宽高比（height/width），与 Swift 版 columnsSize(at:) 逻辑一致（width 固定 100）
@property (nonatomic, copy) NSArray<NSNumber *> *itemAspects;

@end

@implementation WyWaterfallCompositionalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        self.view.backgroundColor = UIColor.whiteColor;
    }
    self.title = @"Waterfall(OC)";

    [self generateMockData];
    [self configureCollectionView];
    [self configureDataSource];
    [self applySnapshot];

    [self addSafeAreaContrastViews];
}

#pragma mark - Data

- (void)generateMockData {
    NSMutableArray<NSString *> *items = [NSMutableArray array];
    NSMutableArray<NSNumber *> *aspects = [NSMutableArray array];

    // Swift: for i in 0 ... 70
    for (NSInteger i = 0; i <= 70; i++) {
        [items addObject:[NSString stringWithFormat:@"Test %ld", (long)i]];

        // Swift: width = 100, height = random(10...300)
        CGFloat randomHeight = (CGFloat)(arc4random_uniform(291) + 10); // 10~300
        CGFloat aspect = randomHeight / 100.0;
        [aspects addObject:@(aspect)];
    }

    self.items = items.copy;
    self.itemAspects = aspects.copy;
}

#pragma mark - View

- (void)configureCollectionView {
    UICollectionViewCompositionalLayout *layout = [self generateCollectionViewLayout];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 13.0, *)) {
        self.collectionView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        self.collectionView.backgroundColor = UIColor.whiteColor;
    }
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:kWyWaterfallCellReuseId];

    [self.view addSubview:self.collectionView];

    // 对齐 Swift：collectionView 贴 safeArea
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
}

- (void)addSafeAreaContrastViews {
    UIView *topContrast = [UIView new];
    if (@available(iOS 13.0, *)) {
        topContrast.backgroundColor = UIColor.systemGrayColor;
    } else {
        topContrast.backgroundColor = UIColor.lightGrayColor;
    }
    [self.view addSubview:topContrast];
    [topContrast mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.mas_topLayoutGuideBottom);
    }];

    UIView *bottomContrast = [UIView new];
    if (@available(iOS 13.0, *)) {
        bottomContrast.backgroundColor = UIColor.systemGrayColor;
    } else {
        bottomContrast.backgroundColor = UIColor.lightGrayColor;
    }
    [self.view addSubview:bottomContrast];
    [bottomContrast mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideTop);
    }];
}

#pragma mark - Diffable

- (void)configureDataSource {
    if (!self.collectionView) { return; }

    __weak typeof(self) weakSelf = self;
    self.dataSource = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView
                                                                            cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSString * _Nonnull itemIdentifier) {
        __strong typeof(weakSelf) self = weakSelf;
        (void)self;

        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWyWaterfallCellReuseId forIndexPath:indexPath];
        if (@available(iOS 13.0, *)) {
            cell.backgroundColor = UIColor.systemPinkColor;
        } else {
            cell.backgroundColor = UIColor.magentaColor;
        }
        return cell;
    }];
}

- (void)applySnapshot {
    if (!self.dataSource) { return; }

    NSDiffableDataSourceSnapshot<NSNumber *, NSString *> *snapshot = [NSDiffableDataSourceSnapshot new];
    NSNumber *section = @0;
    [snapshot appendSectionsWithIdentifiers:@[section]];
    [snapshot appendItemsWithIdentifiers:self.items];
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];
}

#pragma mark - Layout

- (UICollectionViewCompositionalLayout *)generateCollectionViewLayout {
    __weak typeof(self) weakSelf = self;
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return nil; }
        return [self generateWaterfallSectionWithEnvironment:layoutEnvironment];
    }];
    return layout;
}

- (NSCollectionLayoutSection *)generateWaterfallSectionWithEnvironment:(id<NSCollectionLayoutEnvironment>)environment {
    // Swift 对齐：edgeInsets = (top:0, leading:20, bottom:0, trailing:20)
    NSDirectionalEdgeInsets edgeInsets = NSDirectionalEdgeInsetsMake(0, 20, 0, 20);

    // Swift 对齐：2 列、间距 10
    NSInteger numberOfColumns = 2;
    CGFloat space = 10.0;

    CGFloat contentWidth = environment.container.effectiveContentSize.width;
    CGFloat itemWidth = (contentWidth - (CGFloat)(numberOfColumns - 1) * space) / (CGFloat)numberOfColumns;

    // 预计算 frames 与总高度，避免 OC 下 estimated height 触发反复布局的问题
    NSMutableArray<NSNumber *> *columnHeights = [NSMutableArray arrayWithCapacity:numberOfColumns];
    for (NSInteger i = 0; i < numberOfColumns; i++) {
        [columnHeights addObject:@(0)];
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

        CGFloat aspect = 1.0;
        if (i < self.itemAspects.count) {
            aspect = self.itemAspects[i].doubleValue;
        }
        CGFloat itemHeight = itemWidth * aspect;

        CGFloat x = edgeInsets.leading + itemWidth * (CGFloat)targetColumn + space * (CGFloat)targetColumn;
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

    group.contentInsets = edgeInsets;

    return [NSCollectionLayoutSection sectionWithGroup:group];
}

@end


