//
//  SectionPagingViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/3.
//

#import "SectionPagingViewController.h"
#import "SectionPagingCollectionView.h"
#import "SectionPagingFlowLayout.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

@interface SectionPagingCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sectionLabel;

@end

@implementation SectionPagingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [self.contentView addSubview:_titleLabel];
        
        _sectionLabel = [[UILabel alloc] init];
        _sectionLabel.textAlignment = NSTextAlignmentCenter;
        _sectionLabel.font = [UIFont systemFontOfSize:14];
        _sectionLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_sectionLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
        
        [_sectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        }];
    }
    return self;
}

@end

#pragma mark - SectionPagingViewController

@interface SectionPagingViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) SectionPagingCollectionView *collectionView;
@property (nonatomic, strong) SectionPagingFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray<NSArray<NSDictionary *> *> *dataSource;

/// 当前显示的section范围
@property (nonatomic, assign) NSInteger startSectionItemIndex; // 从哪个开始
@property (nonatomic, assign) NSInteger endSectionItemIndex;   // 到哪个结束

@end

@implementation SectionPagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Section分页列表";
    
    [self setupData];
    [self setupViews];
    [self setupRefresh];
}

- (void)setupData {

    self.dataSource = [NSMutableArray array];
    
    // Section2 的数据 (cell3-cell6)
    NSArray *section2Data = @[
        @{@"title": @"Cell100", @"height": @(420), @"section": @"Section 100"},
        @{@"title": @"Cell101", @"height": @(450), @"section": @"Section 100"},
        @{@"title": @"Cell102", @"height": @(200), @"section": @"Section 100"},
        @{@"title": @"Cell103", @"height": @(380), @"section": @"Section 100"}
    ];
    self.startSectionItemIndex = 100;
    self.endSectionItemIndex = 100;
    
    [self.dataSource addObject:section2Data];
}

- (void)setupViews {
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 确保MJRefresh正确初始化
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    self.collectionView.mj_footer.hidden = NO;
}

- (void)setupRefresh {
    // 头部刷新 - 加载上一个section
    [self.collectionView addNovelHeaderWithRefreshingTarget:self refreshingAction:@selector(loadPreviousSection)];
    
    // 尾部刷新 - 加载下一个section
    [self.collectionView addNovelFooterWithRefreshingTarget:self refreshingAction:@selector(loadNextSection)];
}

#pragma mark - Data Loading

- (NSArray *)mockTestSectionData:(BOOL)isPrevious {
    NSString *sectionName = nil;
    if (isPrevious) {
        self.startSectionItemIndex--;
        sectionName = [NSString stringWithFormat:@"Section %zd", self.startSectionItemIndex];
    } else {
        self.endSectionItemIndex++;
        sectionName = [NSString stringWithFormat:@"Section %zd", self.endSectionItemIndex];
    }
    
    NSInteger maxHeight = self.collectionView.frame.size.height;
    NSInteger totalHeight = 0;
    NSMutableArray *newSection = [NSMutableArray array];
    
    for (NSInteger index = 0; index < 100; index++) {
        NSInteger height = arc4random()%500 + 100;
        totalHeight += height;
        [newSection addObject:@{@"title": [NSString stringWithFormat:@"Cell-%zd", index],
                                @"height": @(height),
                                @"section": sectionName}];
        
        if (totalHeight >= maxHeight) {
            break;
        }
    }
    
    return [NSArray arrayWithArray:newSection];
}

- (void)loadPreviousSection {
    if (self.startSectionItemIndex <= 0) {
        [self.collectionView.mj_header endRefreshing];
        self.collectionView.mj_header.hidden = YES;
        return;
    }
    
    NSLog(@"开始加载Section1...");
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        BOOL isFailed = ((arc4random()%4) == 0);
        
        if (isFailed) {
            [self.collectionView.mj_header endRefreshing];
            return;
        }
        
        // Section1 的数据 (cell0-cell2)
        NSArray *section1Data = [self mockTestSectionData:YES];
        
        // 记录插入前的位置信息
        CGFloat oldContentHeight = self.collectionView.contentSize.height;
        CGFloat oldContentOffsetY = self.collectionView.contentOffset.y;
        
        NSLog(@"插入前 - contentHeight: %.2f, contentOffset.y: %.2f", oldContentHeight, oldContentOffsetY);
        
        // 在数组开头插入section1
        [self.dataSource insertObject:section1Data atIndex:0];

        
        // 刷新数据
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        
        // 计算新的contentHeight
        CGFloat newContentHeight = self.collectionView.contentSize.height;
        CGFloat heightDifference = newContentHeight - oldContentHeight;
        
        NSLog(@"插入后 - contentHeight: %.2f, heightDifference: %.2f", newContentHeight, heightDifference);
        
        // 调整contentOffset以保持当前视图位置不变（补偿新增的高度）
        CGPoint newOffset = CGPointMake(0, oldContentOffsetY + heightDifference);
        [self.collectionView setContentOffset:newOffset animated:NO];
        
        NSLog(@"调整后 - contentOffset.y: %.2f", self.collectionView.contentOffset.y);
        
        // 滚动到cell2的底部与列表底部对齐
        // cell2是section1的最后一个cell（section index = 0）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"滚动到Section1的底部对齐...");
            [self.collectionView scrollToAlignBottomOfSection:0 animated:YES];
        });
        
        [self.collectionView.mj_header endRefreshing];
    });
}

- (void)loadNextSection {

    NSLog(@"开始加载Section3...");
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        BOOL isFailed = ((arc4random()%4) == 0);
        
        if (isFailed) {
            [self.collectionView.mj_footer endRefreshing];
            return;
        }
        
        // Section3 的数据 (cell7-cell10)
        NSArray *section3Data = [self mockTestSectionData:NO];
        NSLog(@"添加前 - sections数量: %ld", (long)self.dataSource.count);
        
        // 在数组末尾添加section3
        [self.dataSource addObject:section3Data];
        
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        
        NSLog(@"添加后 - sections数量: %ld, contentHeight: %.2f", 
              (long)self.dataSource.count, 
              self.collectionView.contentSize.height);
        
        // 滚动到cell7的顶部与列表顶部对齐
        // cell7是section3的第一个cell，section3是最后一个section
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger section3Index = self.dataSource.count - 1;
            NSLog(@"滚动到Section3的顶部对齐... section index: %ld", (long)section3Index);
            [self.collectionView scrollToAlignTopOfSection:section3Index animated:YES];
        });
        
        [self.collectionView.mj_footer endRefreshing];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SectionPagingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SectionPagingCollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *data = self.dataSource[indexPath.section][indexPath.item];
    cell.titleLabel.text = data[@"title"];
    cell.sectionLabel.text = data[@"section"];
    
    // 为不同section设置不同背景色
    if (indexPath.section == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
    } else if (indexPath.section == 1) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:1.0];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.dataSource[indexPath.section][indexPath.item];
    CGFloat height = [data[@"height"] floatValue];
    return CGSizeMake(collectionView.bounds.size.width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    SectionPagingCollectionView *pagingCollectionView = (SectionPagingCollectionView *)scrollView;
    [pagingCollectionView shouldSnapToSectionBoundaryWithVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - Getters

- (SectionPagingCollectionView *)collectionView {
    if (!_collectionView) {
        _layout = [[SectionPagingFlowLayout alloc] init];
        _collectionView = [[SectionPagingCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.enableSectionPaging = YES;
        _collectionView.pagingThreshold = 30.0; // 30像素
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        // 确保可以滚动（特别是内容不足一屏时）
        _collectionView.alwaysBounceVertical = YES;
        
        [_collectionView registerClass:[SectionPagingCollectionViewCell class] forCellWithReuseIdentifier:@"SectionPagingCollectionViewCell"];
    }
    return _collectionView;
}

@end

