//
//  UIScrollView+CustomMJRefresh.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/12/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (CustomMJRefresh)

- (void)addNovelHeaderWithRefreshingTarget:(id)target
                          refreshingAction:(SEL)action;

- (void)addNovelFooterWithRefreshingTarget:(id)target
                          refreshingAction:(SEL)action;

@end

NS_ASSUME_NONNULL_END
