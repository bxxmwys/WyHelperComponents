//
//  WaterfallCell.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/7/5.
//

#import "WaterfallCell.h"

@implementation WaterfallCell{
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0
                                               green:arc4random_uniform(256)/255.0
                                                blue:arc4random_uniform(256)/255.0
                                               alpha:1.0];

        _label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:14];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)configureWithText:(NSString *)text {
    _label.text = text;
}

@end
