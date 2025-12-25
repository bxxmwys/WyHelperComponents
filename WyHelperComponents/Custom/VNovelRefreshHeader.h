//
//  VNovelRefreshHeader.h
//  ReelShort
//
//  Created by yansheng wei on 2025/12/04.
//  小说阅读器专用的下拉刷新头部视图
//  特点:
//  1. 使用 Lottie 动画
//  2. 根据下拉距离逐帧播放动画
//  3. 支持 dark/light 主题切换
//  4. 高度为 KSStatusBarHeight + 48，Lottie 底部对齐居中
//

#import <MJRefresh/MJRefreshHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface VNovelRefreshHeader : MJRefreshHeader

@end

NS_ASSUME_NONNULL_END

