//
//  BezierTestViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/5/15.
//

#import "BezierTestViewController.h"
#import "StretchableDialogView.h"
#import "WGradientCurveLineView.h"

@interface BezierTestViewController ()

@property (nonatomic, strong) StretchableDialogView *dialogView;

@property (nonatomic, strong) WGradientCurveLineView *lineView;

@property (nonatomic, strong) UIButton *animationButton;

@property (nonatomic, strong) UISlider *slider;

@end

@implementation BezierTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)setupView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.dialogView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(100);
        make.width.height.mas_equalTo(100);
    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(222);
//        make.leading.mas_equalTo(16);
//        make.trailing.mas_equalTo(-16);
//        make.height.mas_equalTo(6);
//    }];
    
    [self.lineView setPeakCenterRatio:0.75];
    
    self.slider.backgroundColor = UIColor.blackColor;
    self.animationButton.selected = NO;
}

- (StretchableDialogView *)dialogView {
    if (!_dialogView) {
        _dialogView = [[StretchableDialogView alloc] init];
        [self.view addSubview:_dialogView];
    }
    return _dialogView;
}

- (WGradientCurveLineView *)lineView {
    if (!_lineView) {
        _lineView = [[WGradientCurveLineView alloc] initWithFrame:CGRectMake(0, 222, 343, 39)];
        _lineView.backgroundColor = UIColor.blackColor;
        [self.view addSubview:_lineView];
    }
    return _lineView;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 280, 260, 10)];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1.f;
        _slider.value = 0.75;
        [_slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_slider];
    }
    return _slider;
}

- (UIButton *)animationButton {
    if (!_animationButton) {
        _animationButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 280, 80, 40)];
        [_animationButton setTitle:@"正向" forState:UIControlStateNormal];
        [_animationButton setTitle:@"反向" forState:UIControlStateSelected];
        [_animationButton setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
        [_animationButton setTitleColor:UIColor.redColor forState:UIControlStateSelected];
        [_animationButton addTarget:self action:@selector(animationAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_animationButton];
    }
    return _animationButton;
}


- (void)sliderValueChange {
    [self.lineView setPeakCenterRatio:self.slider.value];
}

- (void)animationAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    CGFloat start = sender.isSelected?0.3:0.8;
    CGFloat end = sender.isSelected?0.8:0.3;
    CGFloat duration = 0.5;
    
    [self.lineView animatePeakFrom:start to:end duration:duration];
}

@end
