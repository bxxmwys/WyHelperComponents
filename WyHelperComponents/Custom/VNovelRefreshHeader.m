//
//  VNovelRefreshHeader.m
//  ReelShort
//
//  Created by yansheng wei on 2025/12/04.
//  小说阅读器专用的下拉刷新头部视图
//

#import "VNovelRefreshHeader.h"
#import <Lottie/Lottie.h>
#import "UIView+MJExtension.h"

/// Lottie 动画视图大小
#define kLottieViewSize AdaWidth(24)
#define kHeaderViewHeight (59 + AdaWidth(20+24+20))


@interface VNovelRefreshHeader ()

/// Lottie 动画视图
@property (nonatomic, strong) LOTAnimationView *lottieView;

@end

@implementation VNovelRefreshHeader

#pragma mark - Override Methods

- (void)prepare {
    [super prepare];
 
    // 设置头部视觉高度: 状态栏高度 + Lottie高度（确保不被刘海/灵动岛遮挡）
    self.mj_h = kHeaderViewHeight;
    
    // 添加 Lottie 动画视图
    [self addSubview:self.lottieView];
}

- (void)placeSubviews {
    [super placeSubviews];
    
    // Lottie 视图布局: 水平居中，底部对齐
    CGFloat lottieX = (self.mj_w - kLottieViewSize) / 2.0;
    CGFloat lottieY = self.mj_h - kLottieViewSize - AdaWidth(20);
    self.lottieView.frame = CGRectMake(lottieX, lottieY, kLottieViewSize, kLottieViewSize);
}



#pragma mark - 监听拖拽比例

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    // 先让父类处理基本逻辑
    [super scrollViewContentOffsetDidChange:change];
    
    // 获取当前时间和 offset
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

/// 计算当前的下拉距离（像素）
- (CGFloat)currentPullingDistance {
    UIScrollView *scrollView = self.scrollView;
    if (!scrollView) return 0;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat insetTop = scrollView.contentInset.top;
    CGFloat pullingDistance = -(offsetY + insetTop);
    
    return MAX(pullingDistance, 0);
}

#pragma mark - 监听刷新状态

- (void)setState:(MJRefreshState)state {
    NSLog(@"[MJ][Header][setState] [state = %zd]", state);
    
    MJRefreshCheckState
    
    switch (state) {
        case MJRefreshStateIdle: {
            // 空闲状态: 停止动画，根据拖拽比例显示帧
            [self stopLottieAnimation];
            break;
        }
        case MJRefreshStatePulling: {
            // 拖拽中: 根据拖拽比例逐帧显示（在 scrollViewContentOffsetDidChange 中处理）
            self.lottieView.hidden = NO;
            break;
        }
        case MJRefreshStateRefreshing: {
            // 刷新中: 开始循环播放动画
            [self startLottieAnimation];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Lottie Animation Control

/// 根据下拉比例更新 Lottie 动画进度
/// @param pullingPercent 下拉比例 (0.0 ~ 1.0+)
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
    self.lottieView.hidden = YES;
    self.lottieView.animationProgress = 0;
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

