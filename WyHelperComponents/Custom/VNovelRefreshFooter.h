//
//  VNovelRefreshFooter.h
//  ReelShort
//
//  Created by yansheng wei on 2025/12/04.
//  小说阅读器专用的上拉加载更多尾部视图
//  特点:
//  1. 使用 Lottie 动画
//  2. 根据上拉距离逐帧播放动画
//  3. 支持 dark/light 主题切换
//  4. 高度为 48，Lottie 底部对齐居中
//

#import <MJRefresh/MJRefreshAutoFooter.h>

NS_ASSUME_NONNULL_BEGIN

/// 小说阅读器专用上拉加载 Footer
/// 使用 MJRefreshAutoFooter 作为基类，避免 BackFooter 的 offset 跳动问题
@interface VNovelRefreshFooter : MJRefreshBackFooter

@end

NS_ASSUME_NONNULL_END

