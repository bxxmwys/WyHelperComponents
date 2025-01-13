//
//  WyBaseNavigationController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/6.
//

#import "WyBaseNavigationController.h"

@interface WyBaseNavigationController ()

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation WyBaseNavigationController


// 返回按钮的回调方法
- (void)backAction {
    [self popViewControllerAnimated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
        
    // 航栏相关适配
//    [self setNavBar];
}

- (void)dealloc{
    NSLog(@" dealloc %s", __func__);
}
//
//// 导航栏相关适配
//- (void)setNavBar{
//    if (@available(iOS 13.0, *)){
//        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
//        // 去掉阴影线
//        appearance.shadowImage = [UIImage imageWithColor:[UIColor clearColor]];
//        // 导航栏背景色
//        appearance.backgroundColor = [UIColor Y_ColorWithHex:@"#000000"];
//        // 设置背景色此代码非常重要（默认translucent = YES：backgroundEffect高斯模糊会开启，导致滑动的时候backgroundEffect（灰色半透明）会透出导航栏，将此view设置为空解决；设置translucent = NO也可以解决，但是布局起始位置会发生改变）
//        appearance.backgroundEffect = nil;
//        // 导航栏文字颜色
//        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor Y_ColorWithHex:@"#FFFFFF"],NSFontAttributeName : SOMediumFontSize(IsPad ? 20 : 18)};
//        if (@available(iOS 15.0, *)){
//            self.navigationBar.scrollEdgeAppearance = appearance;
//        }
//        self.navigationBar.standardAppearance = appearance;
//    }else{
//        UINavigationBar *navBar = [UINavigationBar appearance];
//        // 导航栏背景色
//        [navBar setBackgroundImage:[UIImage imageWithColor:[UIColor Y_ColorWithHex:@"#000000"]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//        // 去掉阴影线
//        [navBar setShadowImage:[UIImage new]];
//        // 导航栏文字颜色
//        [navBar setTintColor:[UIColor Y_ColorWithHex:@"#FFFFFF"]];
//        [navBar setBarTintColor:[UIColor Y_ColorWithHex:@"#000000"]];
//        [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor Y_ColorWithHex:@"#FFFFFF"], NSFontAttributeName : SOMediumFontSize(IsPad ? 20 : 18)}];
//        navBar.backItem.titleView.frame = CGRectMake(0, 0, 0, 0);
//    }
//    // 返回按钮
//    UIImage *image = VImage(@"v_btn_back");
//    [self.backButton setImage:image forState:UIControlStateNormal];
//}
//
//
////push时隐藏tabbar
//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if([self.viewControllers containsObject:viewController]) {
//        YLog(@"\n 插入已存在的VC： %@",viewController);
//        return;
//    }
//    if (self.viewControllers.count > 0) {
//        viewController.hidesBottomBarWhenPushed = YES;
//        UIImage *image = VImage(@"v_btn_back");
//        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.backButton setImage:image forState:UIControlStateNormal];
//        [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.backButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.backButton sizeToFit];
//
//        // 注意:一定要在按钮内容有尺寸的时候,设置才有效果
//        CGFloat offset = -28;// 20.5期 美术刘漩 把间距从18 改成16
//        self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, offset, 0, 0);
//        self.backButton.frame = CGRectMake(0, 0, 44, 44);
//        // 设置返回按钮
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
//    }
//    [super pushViewController:viewController animated:animated];
//}


#pragma mark - 设置状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
