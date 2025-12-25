//
//  VNovelRefreshFooter.m
//  ReelShort
//
//  Created by yansheng wei on 2025/12/04.
//  小说阅读器专用的上拉加载更多尾部视图
//  使用 MJRefreshAutoFooter 避免 BackFooter 的 offset 跳动问题
//

#import "VNovelRefreshFooter.h"
#import "UIView+MJExtension.h"
#import <Lottie/Lottie.h>

/// Lottie 动画视图大小
#define kLottieViewSize AdaWidth(24)
#define kFooterViewHeight AdaWidth(32+24+32)

@interface VNovelRefreshFooter ()

/// Lottie 动画视图
@property (nonatomic, strong) LOTAnimationView *lottieView;


@end

@implementation VNovelRefreshFooter

#pragma mark - Override Methods

- (void)prepare {
    [super prepare];
    
    // 设置尾部高度: 60
    self.mj_h = kFooterViewHeight;
    
    // 添加 Lottie 动画视图
    [self addSubview:self.lottieView];
}

- (void)placeSubviews {
    [super placeSubviews];
    
    // Lottie 视图布局: 居中对齐
    CGFloat lottieX = (self.mj_w - kLottieViewSize) / 2.0;
    CGFloat lottieY = (self.mj_h - kLottieViewSize) / 2.0;
    self.lottieView.frame = CGRectMake(lottieX, lottieY, kLottieViewSize, kLottieViewSize);
}

#pragma mark - 监听滚动

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
 
    CGFloat pullingDistance = [self currentPullingDistance];
    
    // 只有在 Idle 或 Pulling 状态下才处理
    if (self.state == MJRefreshStateIdle || self.state == MJRefreshStatePulling) {
        // 更新 Lottie 动画进度（基于触发阈值）
        CGFloat animationProgress = pullingDistance / kRefreshTriggerThreshold;
        [self updateLottieProgressWithPullingPercent:animationProgress];
        
        // 自定义状态切换：下拉超过阈值就进入 Pulling 状态
        if (self.state == MJRefreshStateIdle && pullingDistance >= kRefreshTriggerThreshold) {
            NSLog(@"[MJ][DidChange] - [pullingDistance:%.f] to MJRefreshStatePulling", pullingDistance);
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && pullingDistance < kRefreshTriggerThreshold) {
            NSLog(@"[MJ][DidChange] - [pullingDistance:%.f] to MJRefreshStateIdle", pullingDistance);
            self.state = MJRefreshStateIdle;
        }
    }
}

#pragma mark - 监听刷新状态

- (void)setState:(MJRefreshState)state {
    NSLog(@"[MJ][Footer][setState] [state = %zd]", state);
    MJRefreshCheckState
    
    switch (state) {
        case MJRefreshStateIdle: {
            // 空闲状态: 停止动画
            [self stopLottieAnimation];
            break;
        }
        case MJRefreshStateRefreshing: {
            // 刷新中: 开始循环播放动画
            [self startLottieAnimation];
            break;
        }
        case MJRefreshStateNoMoreData: {
            // 没有更多数据: 停止动画并隐藏
            [self stopLottieAnimation];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Lottie Animation Control

/// 计算当前的拉动比例
- (CGFloat)currentPullingDistance {
    UIScrollView *scrollView = self.scrollView;
    if (!scrollView) return 0;
    
    // 计算已经超出底部的距离
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    CGFloat insetTop = scrollView.contentInset.top;
    CGFloat insetBottom = scrollView.contentInset.bottom;
    
    // 内容不足一屏时的处理
    CGFloat happenOffsetY = MAX(contentHeight - scrollViewHeight + insetBottom, -insetTop);
    
    // 计算超出底部的距离
    CGFloat pullingDistance = offsetY - happenOffsetY;
    
    if (pullingDistance <= 0) {
        return 0;
    }
    
    return pullingDistance;
}

/// 根据上拉比例更新 Lottie 动画进度
/// @param pullingPercent 上拉比例 (0.0 ~ 1.0+)
- (void)updateLottieProgressWithPullingPercent:(CGFloat)pullingPercent {
    // 限制范围在 0 ~ 1
    CGFloat progress = MIN(MAX(pullingPercent, 0.0), 1.0);
    
    // 显示 Lottie 视图
    self.lottieView.hidden = (progress <= 0);
    
    // 设置动画进度（逐帧显示）
    self.lottieView.animationProgress = progress;
}

/// 开始 Lottie 循环动画
- (void)startLottieAnimation {
    self.lottieView.hidden = NO;
    self.lottieView.loopAnimation = YES;
    [self.lottieView play];
}

/// 停止 Lottie 动画
- (void)stopLottieAnimation {
    [self.lottieView stop];
    self.lottieView.animationProgress = 0;
    self.lottieView.hidden = YES;
}

#pragma mark - Getters

- (LOTAnimationView *)lottieView {
    if (!_lottieView) {
        _lottieView = [LOTAnimationView animationNamed:@"novel_load_light.json"];
        _lottieView.userInteractionEnabled = NO;
        _lottieView.hidden = YES;
        _lottieView.loopAnimation = NO;
        _lottieView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _lottieView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
