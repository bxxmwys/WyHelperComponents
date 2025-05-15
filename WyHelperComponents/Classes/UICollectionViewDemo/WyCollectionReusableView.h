//
//  WyCollectionReusableView.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/8.
//

#import <UIKit/UIKit.h>

#define kVEarnRewardV21ElementKindHeader  @"vEarnRewardV21ElementKindHeader"
#define kVEarnRewardV21HeaderHeight (131)
#define kVEarnRewardV21ElementKindFooter  @"vEarnRewardV21ElementKindFooter"
#define kVEarnRewardV21FooterHeight (65)

NS_ASSUME_NONNULL_BEGIN

@interface WyCollectionReusableView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
