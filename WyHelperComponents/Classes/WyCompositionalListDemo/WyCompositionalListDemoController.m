//
//  WyCompositionalListDemoController.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoController.h"

#import "WyCompositionalListView.h"
#import "WyCompositionalListDemoSectionsAssembly.h"

@interface WyCompositionalListDemoController ()
@property (nonatomic, strong) WyCompositionalListView *listView;
@end

@implementation WyCompositionalListDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"WyCompositionalList Demo";

    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];

    [self.listView setSections:[WyCompositionalListDemoSectionsAssembly buildSections] animated:NO];
}

- (WyCompositionalListView *)listView {
    if (!_listView) {
        _listView = [[WyCompositionalListView alloc] initWithFrame:self.view.bounds];
        _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_listView];
    }
    return _listView;
}

@end

