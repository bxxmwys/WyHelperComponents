//
//  StretchableDialogView.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/3/30.
//

#import "StretchableDialogView.h"

@implementation StretchableDialogView{
    CAGradientLayer *_linearGradientLayer;
    CAGradientLayer *_radialGradientLayer;
    CAShapeLayer *_shapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = UIColor.clearColor;
    _shapeLayer = [CAShapeLayer layer];
    
    _linearGradientLayer = [CAGradientLayer layer];
    _linearGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:1.0 green:0.68 blue:0.54 alpha:0.6].CGColor,
                                    (__bridge id)[UIColor colorWithWhite:0 alpha:0.3].CGColor];
    _linearGradientLayer.startPoint = CGPointMake(0.5, 0);
    _linearGradientLayer.endPoint = CGPointMake(0.5, 1);
    
    _radialGradientLayer = [CAGradientLayer layer];
    _radialGradientLayer.type = kCAGradientLayerRadial;
    _radialGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:1 green:0.23 blue:0.05 alpha:1.0].CGColor,
                                    (__bridge id)[UIColor colorWithWhite:0.07 alpha:0].CGColor];
    _radialGradientLayer.startPoint = CGPointMake(0.4479, 1.3488); // 注意坐标系归一化
    _radialGradientLayer.endPoint = CGPointMake(0.4479 + 1.4586, 1.3488 + 1.6284); // 计算径向范围
    
    [self.layer addSublayer:_linearGradientLayer];
    [self.layer addSublayer:_radialGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    UIBezierPath *path = [self createBezierPathWithWidth:width height:height];
    _shapeLayer.path = path.CGPath;

    _linearGradientLayer.frame = self.bounds;
    _radialGradientLayer.frame = self.bounds;
    _shapeLayer.frame = self.bounds;
    
    self.layer.mask = _shapeLayer;
}

- (UIBezierPath *)createBezierPathWithWidth:(CGFloat)width height:(CGFloat)height {
    CGFloat cornerRadius = 6.4;
    CGFloat tailWidth = 8;
    CGFloat tailHeight = 4;
    CGFloat tailOffset = 0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, cornerRadius)];
    [path addQuadCurveToPoint:CGPointMake(cornerRadius, 0) controlPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(width - cornerRadius, 0)];
    [path addQuadCurveToPoint:CGPointMake(width, cornerRadius) controlPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(width, height - cornerRadius - tailHeight)];
    [path addQuadCurveToPoint:CGPointMake(width - cornerRadius, height-tailHeight) controlPoint:CGPointMake(width, height-tailHeight)];
    [path addLineToPoint:CGPointMake(width / 2 + tailOffset + tailWidth / 2, height-tailHeight)];
    [path addLineToPoint:CGPointMake(width / 2 + tailOffset, height)];
    [path addLineToPoint:CGPointMake(width / 2 + tailOffset - tailWidth / 2, height-tailHeight)];
    [path addLineToPoint:CGPointMake(cornerRadius, height-tailHeight)];
    [path addQuadCurveToPoint:CGPointMake(0, height - cornerRadius - tailHeight) controlPoint:CGPointMake(0, height-tailHeight)];
    [path closePath];
    
    return path;
}

@end
