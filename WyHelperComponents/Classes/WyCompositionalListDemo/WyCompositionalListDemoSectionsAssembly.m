//
//  WyCompositionalListDemoSectionsAssembly.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoSectionsAssembly.h"

#import "WyCompositionalListDemoSimpleVM.h"
#import "WyCompositionalListDemoRankArraySection.h"
#import "WyCompositionalListDemoWaterfallVM.h"
#import "WyCompositionalListDemoWaterfallSection.h"
#import "WyCompositionalListDemoHorizontalTextSection.h"
#import "WyCompositionalListDemoHorizontalWaterfallCellSection.h"
#import "WyCompositionalListDemoGridSection.h"

@implementation WyCompositionalListDemoSectionsAssembly

+ (NSArray<id<WyCompositionalListSection>> *)buildSections {
    // 只在这里管理“启用哪些 Section + 顺序”

    NSMutableArray<id<WyCompositionalListSection>> *sections = [NSMutableArray array];

    // 0) 复刻：sectionForRankArray
    {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 18; i++) {
            [items addObject:[NSString stringWithFormat:@"Rank-%ld", (long)(i + 1)]];
        }
        WyCompositionalListDemoSimpleVM *vm =
        [[WyCompositionalListDemoSimpleVM alloc] initWithSectionID:@"rank_array"
                                                            header:@"复刻：RankArray"
                                                            footer:@"Footer"
                                                           itemIDs:items];
        WyCompositionalListDemoRankArraySection *s = [[WyCompositionalListDemoRankArraySection alloc] initWithViewModel:vm];
        [sections addObject:s];
    }

    // 1) 同一个模板 Section（水平滚动）复用两次：仅尺寸不同
    {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 12; i++) {
            [items addObject:[NSString stringWithFormat:@"Small-%ld", (long)(i + 1)]];
        }
        WyCompositionalListDemoSimpleVM *vm =
        [[WyCompositionalListDemoSimpleVM alloc] initWithSectionID:@"hor_text_small"
                                                            header:@"水平滚动：文本（小卡片）"
                                                            footer:nil
                                                           itemIDs:items];
        WyCompositionalListDemoHorizontalTextSection *s = [[WyCompositionalListDemoHorizontalTextSection alloc] initWithViewModel:vm];
        s.itemWidth = 88;
        s.itemHeight = 88;
        [sections addObject:s];
    }

    {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 8; i++) {
            [items addObject:[NSString stringWithFormat:@"Large-%ld", (long)(i + 1)]];
        }
        WyCompositionalListDemoSimpleVM *vm =
        [[WyCompositionalListDemoSimpleVM alloc] initWithSectionID:@"hor_text_large"
                                                            header:@"水平滚动：文本（大卡片）"
                                                            footer:nil
                                                           itemIDs:items];
        WyCompositionalListDemoHorizontalTextSection *s = [[WyCompositionalListDemoHorizontalTextSection alloc] initWithViewModel:vm];
        s.itemWidth = 160;
        s.itemHeight = 120;
        [sections addObject:s];
    }

    // 2) 同为水平滚动，但使用不同 cell（演示“同模板不同 Cell”）
    {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 10; i++) {
            [items addObject:[NSString stringWithFormat:@"WF-%ld", (long)(i + 1)]];
        }
        WyCompositionalListDemoSimpleVM *vm =
        [[WyCompositionalListDemoSimpleVM alloc] initWithSectionID:@"hor_waterfall_cell"
                                                            header:@"水平滚动：WaterfallCell"
                                                            footer:nil
                                                           itemIDs:items];
        WyCompositionalListDemoHorizontalWaterfallCellSection *s =
        [[WyCompositionalListDemoHorizontalWaterfallCellSection alloc] initWithViewModel:vm];
        s.itemWidth = 120;
        s.itemHeight = 100;
        [sections addObject:s];
    }

    // 3) 竖向网格：另一种样式
    {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSInteger i = 0; i < 15; i++) {
            [items addObject:[NSString stringWithFormat:@"Grid-%ld", (long)(i + 1)]];
        }
        WyCompositionalListDemoSimpleVM *vm =
        [[WyCompositionalListDemoSimpleVM alloc] initWithSectionID:@"grid_3col"
                                                            header:@"竖向网格：3 列"
                                                            footer:nil
                                                           itemIDs:items];
        WyCompositionalListDemoGridSection *s = [[WyCompositionalListDemoGridSection alloc] initWithViewModel:vm];
        [sections addObject:s];
    }

    // 4) 复刻：瀑布流 generateWaterfallSectionWithEnvironment
    {
        NSMutableArray<NSString *> *itemIDs = [NSMutableArray array];
        NSMutableDictionary<NSString *, NSNumber *> *heightByID = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < 30; i++) {
            NSString *itemID = [NSString stringWithFormat:@"WF-%ld", (long)(i + 1)];
            [itemIDs addObject:itemID];
            heightByID[itemID] = @(arc4random_uniform(100) + 100);
        }
        WyCompositionalListDemoWaterfallVM *vm =
        [[WyCompositionalListDemoWaterfallVM alloc] initWithSectionID:@"waterfall"
                                                               header:@"复刻：Waterfall"
                                                               footer:@"Footer"
                                                              itemIDs:itemIDs
                                                           heightByID:heightByID];
        WyCompositionalListDemoWaterfallSection *s = [[WyCompositionalListDemoWaterfallSection alloc] initWithViewModel:vm];
        [sections addObject:s];
    }

    return sections;
}

@end

