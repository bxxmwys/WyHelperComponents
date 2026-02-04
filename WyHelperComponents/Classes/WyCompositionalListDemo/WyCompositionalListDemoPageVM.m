//
//  WyCompositionalListDemoPageVM.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import "WyCompositionalListDemoPageVM.h"

@interface WyCompositionalListDemoPageVM ()
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<id<NSCopying>> *> *itemsBySectionID;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headerBySectionID;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *footerBySectionID;
@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary<id<NSCopying>, NSNumber *> *> *heightBySectionAndItem;
@end

@implementation WyCompositionalListDemoPageVM

+ (instancetype)demoVM {
    WyCompositionalListDemoPageVM *vm = [WyCompositionalListDemoPageVM new];

    NSMutableDictionary<NSString *, NSArray<id<NSCopying>> *> *items = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *footers = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSDictionary<id<NSCopying>, NSNumber *> *> *heights = [NSMutableDictionary dictionary];

    // rank array
    {
        NSString *sid = @"rank_array";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < 18; i++) { [arr addObject:[NSString stringWithFormat:@"Rank-%ld", (long)(i + 1)]]; }
        items[sid] = arr;
        headers[sid] = @"复刻：RankArray";
        footers[sid] = @"Footer";
    }

    // horizontal text (small)
    {
        NSString *sid = @"hor_text_small";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < 12; i++) { [arr addObject:[NSString stringWithFormat:@"Small-%ld", (long)(i + 1)]]; }
        items[sid] = arr;
        headers[sid] = @"水平滚动：文本（小卡片）";
    }

    // horizontal text (large)
    {
        NSString *sid = @"hor_text_large";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < 8; i++) { [arr addObject:[NSString stringWithFormat:@"Large-%ld", (long)(i + 1)]]; }
        items[sid] = arr;
        headers[sid] = @"水平滚动：文本（大卡片）";
    }

    // horizontal waterfall cell
    {
        NSString *sid = @"hor_waterfall_cell";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i++) { [arr addObject:[NSString stringWithFormat:@"WF-%ld", (long)(i + 1)]]; }
        items[sid] = arr;
        headers[sid] = @"水平滚动：WaterfallCell";
    }

    // grid
    {
        NSString *sid = @"grid_3col";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < 15; i++) { [arr addObject:[NSString stringWithFormat:@"Grid-%ld", (long)(i + 1)]]; }
        items[sid] = arr;
        headers[sid] = @"竖向网格：3 列";
    }

    // waterfall
    {
        NSString *sid = @"waterfall";
        NSMutableArray<NSString *> *arr = [NSMutableArray array];
        NSMutableDictionary<id<NSCopying>, NSNumber *> *heightMap = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < 30; i++) {
            NSString *itemID = [NSString stringWithFormat:@"WF-%ld", (long)(i + 1)];
            [arr addObject:itemID];
            heightMap[itemID] = @(arc4random_uniform(100) + 100);
        }
        items[sid] = arr;
        headers[sid] = @"复刻：Waterfall";
        footers[sid] = @"Footer";
        heights[sid] = heightMap;
    }

    vm.itemsBySectionID = items;
    vm.headerBySectionID = headers;
    vm.footerBySectionID = footers;
    vm.heightBySectionAndItem = heights;
    return vm;
}

- (NSArray<id<NSCopying>> *)itemIDsForSectionID:(NSString *)sectionID {
    return self.itemsBySectionID[sectionID] ?: @[];
}

- (NSString *)headerTitleForSectionID:(NSString *)sectionID {
    return self.headerBySectionID[sectionID];
}

- (NSString *)footerTitleForSectionID:(NSString *)sectionID {
    return self.footerBySectionID[sectionID];
}

- (CGFloat)heightForItemID:(id<NSCopying>)itemID sectionID:(NSString *)sectionID {
    NSDictionary<id<NSCopying>, NSNumber *> *map = self.heightBySectionAndItem[sectionID];
    return map[itemID].doubleValue;
}

@end

