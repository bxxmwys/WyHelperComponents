//
//  UIScrollView+CustomMJRefresh.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/12/25.
//

#import "UIScrollView+CustomMJRefresh.h"
#import <MJRefresh/MJRefresh.h>
#import "VNovelRefreshFooter.h"
#import "VNovelRefreshHeader.h"

@implementation UIScrollView (CustomMJRefresh)

- (void)addNovelHeaderWithRefreshingTarget:(id)target
                          refreshingAction:(SEL)action {
    VNovelRefreshHeader *header = [VNovelRefreshHeader headerWithRefreshingTarget:target refreshingAction:action];
    self.mj_header = header;
}

- (void)addNovelFooterWithRefreshingTarget:(id)target
                          refreshingAction:(SEL)action {
    VNovelRefreshFooter *footer = [VNovelRefreshFooter footerWithRefreshingTarget:target refreshingAction:action];
    self.mj_footer = footer;
    self.mj_footer.hidden = YES;
}

@end
