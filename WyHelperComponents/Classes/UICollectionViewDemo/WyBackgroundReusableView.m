//
//  WyBackgroundReusableView.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/8.
//

#import "WyBackgroundReusableView.h"

@implementation WyBackgroundReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    self.layer.cornerRadius = 6;
    self.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor redColor];
}

@end
