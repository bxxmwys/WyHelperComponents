//
//  WGradientCurveLineView.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/6/17.
//

#import "WGradientCurveLineView.h"

#define kTailWidth (16)
#define kTailHeight (4)
#define kTailRadius (1)

@interface WGradientCurveLineView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) CAGradientLayer *ellipseGradientLayer; // 椭圆渐变层
//@property (nonatomic, strong) CALayer *ellipseContainerLayer;        // 用于控制位置和模糊的容器

@property (nonatomic, assign) CGFloat currentPeakRatio;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationStartRatio;
@property (nonatomic, assign) CGFloat animationEndRatio;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, assign) CFTimeInterval animationDuration;

@end

@implementation WGradientCurveLineView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers {
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineWidth = 1;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineJoin = kCALineJoinRound;

    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.startPoint = CGPointMake(0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1, 0.5);
    self.gradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:1 green:222/255.f blue:144/255.f alpha:0.0].CGColor,
        (__bridge id)[UIColor colorWithRed:1 green:222/255.f blue:144/255.f alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:1 green:222/255.f blue:144/255.f alpha:0.0].CGColor
    ];
    self.gradientLayer.locations = @[@0.3, @0.5, @0.7];
    self.gradientLayer.mask = self.shapeLayer;

    // ✅ 添加椭圆背景渐变
    self.ellipseGradientLayer = [CAGradientLayer layer];
    self.ellipseGradientLayer.type = kCAGradientLayerRadial;
    self.ellipseGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:1 green:222/255.f blue:144/255.f alpha:0.7].CGColor,
                                         (__bridge id)[UIColor colorWithRed:1 green:222/255.f blue:144/255.f alpha:0.0].CGColor];
    self.ellipseGradientLayer.startPoint = CGPointMake(0.5, 0.5); // 注意坐标系归一化
    self.ellipseGradientLayer.endPoint = CGPointMake(0.5+0.5, 0.5 + 0.5); // 计算径向范围
    self.ellipseGradientLayer.bounds = CGRectMake(0, 0, 172, 78);
    
    // 椭圆层的遮罩层
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.ellipseGradientLayer.bounds;

    UIBezierPath *maskPath = [self createBezierPathWithWidth:self.ellipseGradientLayer.bounds.size.width height:self.ellipseGradientLayer.bounds.size.height/2 - 1];

    maskLayer.path = maskPath.CGPath;
    self.ellipseGradientLayer.mask = maskLayer;

    
    [self.layer addSublayer:self.ellipseGradientLayer];
    [self.layer addSublayer:self.gradientLayer];
    self.layer.masksToBounds = YES;

    self.currentPeakRatio = 0.5;
    [self updatePathAndGradient];
}


- (UIBezierPath *)createBezierPathWithWidth:(CGFloat)width height:(CGFloat)height {
    CGFloat tailRadius = kTailRadius;
    CGFloat tailWidth = kTailWidth;
    CGFloat tailHeight = kTailHeight;
    CGFloat tailOffset = 0;
    
    // 中心x
    CGFloat centerX = width / 2 + tailOffset;
    // 中心y
    CGFloat peakY = height - tailHeight;
    // 圆角起始Y
    CGFloat peakSY = peakY - tailRadius/2;
    // 圆角起始左x
    CGFloat peakLx = centerX - tailRadius/2;
    // 圆角起始右x
    CGFloat peakRx = centerX + tailRadius/2;

    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(centerX + tailWidth / 2, height)];
    [path addLineToPoint:CGPointMake(peakRx, peakSY)];
    // 画圆角
    [path addQuadCurveToPoint:CGPointMake(peakLx, peakSY)
                 controlPoint:CGPointMake(centerX, peakY)];
    
    [path addLineToPoint:CGPointMake(centerX - tailWidth / 2, height)];
    [path addLineToPoint:CGPointMake(0, height)];
    
    [path closePath];
    
    return path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
    [self updatePathAndGradient];
}

/// 设置凸点中心比例（0 ~ 1）
- (void)setPeakCenterRatio:(CGFloat)ratio {
    self.currentPeakRatio = MAX(0, MIN(1, ratio));
    [self updatePathAndGradient];
}

- (void)updatePathAndGradient {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat tailRadius = kTailRadius;
    CGFloat tailWidth = kTailWidth;
    CGFloat tailHeight = kTailHeight;
    
    CGFloat peakMaxY = height - 1;
    // 中心x
    CGFloat peakX = self.currentPeakRatio * width;
    // 中心y
    CGFloat peakY = peakMaxY - tailHeight;
    // 圆角起始Y
    CGFloat peakSY = peakY - tailRadius/2;
    // 圆角起始左x
    CGFloat peakLx = peakX - tailRadius/2;
    // 圆角起始右x
    CGFloat peakRx = peakX + tailRadius/2;
    

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, peakMaxY)];
    [path addLineToPoint:CGPointMake(peakX - tailWidth / 2, peakMaxY)];
    [path addLineToPoint:CGPointMake(peakLx, peakSY)];
    [path addQuadCurveToPoint:CGPointMake(peakRx, peakSY)
                 controlPoint:CGPointMake(peakX, peakY)];
    [path addLineToPoint:CGPointMake(peakX + tailWidth / 2, peakMaxY)];
    [path addLineToPoint:CGPointMake(width, peakMaxY)];
    self.shapeLayer.path = path.CGPath;

    CGFloat left = 0;
    CGFloat right = 1;

    CGPoint ellipseCenter = CGPointMake(peakX, height);

    // ✅ 关闭所有变化的隐式动画（渐变位置 + 椭圆位置）
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    self.gradientLayer.locations = @[@(left), @(self.currentPeakRatio), @(right)];
    self.ellipseGradientLayer.position = ellipseCenter;

    [CATransaction commit];
}

- (void)animatePeakFrom:(CGFloat)start to:(CGFloat)end duration:(NSTimeInterval)duration {
    [self.displayLink invalidate]; // 清理旧的动画
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    self.animationStartRatio = start;
    self.animationEndRatio = end;
    self.animationStartTime = CACurrentMediaTime();
    self.animationDuration = duration;
}

- (void)handleDisplayLink:(CADisplayLink *)link {
    CFTimeInterval elapsed = CACurrentMediaTime() - self.animationStartTime;
    CGFloat progress = elapsed / self.animationDuration;
    if (progress >= 1.0) {
        self.currentPeakRatio = self.animationEndRatio;
        [self updatePathAndGradient];
        [self.displayLink invalidate];
        self.displayLink = nil;
        return;
    }

    // ⚠️ 可选：加入缓动函数（EaseInOut 等）
    CGFloat easedProgress = 0.5 * (1 - cos(progress * M_PI)); // cosine 缓动
    self.currentPeakRatio = self.animationStartRatio + (self.animationEndRatio - self.animationStartRatio) * easedProgress;

    [self updatePathAndGradient];
}

@end
