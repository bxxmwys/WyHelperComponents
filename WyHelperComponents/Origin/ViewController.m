//
//  ViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/3.
//

#import "ViewController.h"
#import "WyCompositionalLayoutController.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, nullable) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *dataSourceDictionary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSourceDictionary = @{
        @"CompositionalLayout":@"WyCompositionalLayoutController",
        @"GCD":@"GCDTestViewController",
        @"Bezier":@"BezierTestViewController",
        @"UILael":@"UILabelTestViewController",
//        @"":@"",
    };
    
    [self setupView];
}

- (void)setupView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

#pragma mark - UITableViewDataSource&UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceDictionary.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = [self.dataSourceDictionary.allKeys objectAtIndex:indexPath.item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = [self.dataSourceDictionary.allValues objectAtIndex:indexPath.item];
    Class cls = NSClassFromString(className);
    id instance = [[cls alloc] init];
    [self.navigationController pushViewController:instance animated:YES];
}


#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView.alloc initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
