//
//  WGradientCurveLineView.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WGradientCurveLineView : UIView

/// 设置当前渐变中心点（0.0 ~ 1.0之间）
- (void)setPeakCenterRatio:(CGFloat)ratio;

/// 设置动画
- (void)animatePeakFrom:(CGFloat)start to:(CGFloat)end duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
