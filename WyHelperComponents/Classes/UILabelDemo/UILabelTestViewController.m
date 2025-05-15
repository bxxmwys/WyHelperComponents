//
//  UILabelTestViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/5/15.
//

#import "UILabelTestViewController.h"

@interface UILabelTestViewController ()

@property (nonatomic, strong) UILabel *autoFitLabel;

@end

@implementation UILabelTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UILabel *)autoFitLabel {
    if (!_autoFitLabel) {
        _autoFitLabel = UILabel.new;
        _autoFitLabel.backgroundColor = UIColor.greenColor;
        _autoFitLabel.textColor = UIColor.redColor;
        _autoFitLabel.numberOfLines = 2;
        _autoFitLabel.adjustsFontSizeToFitWidth = YES;
        _autoFitLabel.minimumScaleFactor = 0.7;
        _autoFitLabel.font = [UIFont systemFontOfSize:20];
        _autoFitLabel.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
        _autoFitLabel.text = @"fdsfsfssdfasfsfsafhskfdksfjsfhkjshfkjkjsfhksfjhfkjsfdksahfhfkdjsfhsa1234564";
    }
    return _autoFitLabel;
}

@end
