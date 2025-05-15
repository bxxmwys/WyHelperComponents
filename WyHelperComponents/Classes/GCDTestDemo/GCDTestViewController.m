//
//  GCDTestViewController.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/5/15.
//

#import "GCDTestViewController.h"

@interface GCDTestViewController ()

@end

@implementation GCDTestViewController{
    dispatch_queue_t _syncQueue;        // 用于线程同步操作
    dispatch_source_t _transSource;    // 延时事务定时器
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    // 使用实例的内存地址作为队列名字的一部分，确保每个实例的队列名字唯一
    //    NSString *queueLabel = [NSString stringWithFormat:@"cms.reelShort.reportMemoryCache.syncQueue-%p", self];
    //    _syncQueue = dispatch_queue_create([queueLabel UTF8String], DISPATCH_QUEUE_CONCURRENT);
    //
    //    [self startReportTimer];
    //
    //    dispatch_barrier_async(_syncQueue, ^{
    //        sleep(10);
    //        NSLog(@"test 1111");
    //    });
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        dispatch_barrier_async(_syncQueue, ^{
    //            NSLog(@"test 6666");
    //            sleep(7);
    //        });
    //    });
}

// 启动延时5秒的上报任务
- (void)startReportTimer {
    if (_transSource) {
        return; // 如果已有定时器，直接返回
    }
    
    // 创建延时任务
    _transSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _syncQueue);
    dispatch_source_set_timer(_transSource, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), 2 * NSEC_PER_SEC, 0);
    
    // 设置定时器触发时的回调
    @weakify(self)
    dispatch_source_set_event_handler(_transSource, ^{
        @strongify(self)
        if (!self) return;
        NSLog(@"test 2222");
        sleep(10);
        dispatch_barrier_async(self->_syncQueue, ^{
            // 开启事务
            NSLog(@"test 3333");
        });
    });
    
    NSLog(@"test 0000");
    // 启动定时器
    dispatch_resume(_transSource);
}


@end
