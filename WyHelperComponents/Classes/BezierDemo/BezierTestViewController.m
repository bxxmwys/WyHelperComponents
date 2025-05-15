//
//  BezierTestViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/5/15.
//

#import "BezierTestViewController.h"
#import "StretchableDialogView.h"

@interface BezierTestViewController ()

@property (nonatomic, strong) StretchableDialogView *dialogView;

@end

@implementation BezierTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (StretchableDialogView *)dialogView {
    if (!_dialogView) {
        _dialogView = [[StretchableDialogView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.view addSubview:_dialogView];
    }
    return _dialogView;
}

@end
