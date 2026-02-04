//
//  WyCompositionalListDemoSectionsAssembly.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoSectionsAssembly.h"

#import "WyCompositionalListDemoPageVM.h"

#import "WyCompositionalListShelfSection.h"

#import "WyCollectionViewCell.h"
#import "WaterfallCell.h"

@implementation WyCompositionalListDemoSectionsAssembly

+ (NSArray<id<WyCompositionalListSection>> *)buildSections {
    // 只在这里管理“启用哪些 Section + 顺序”

    WyCompositionalListDemoPageVM *pageVM = [WyCompositionalListDemoPageVM demoVM];

    NSMutableArray<id<WyCompositionalListSection>> *sections = [NSMutableArray array];

    // 0) 复刻：RankArray（sectionForRankArray）
    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleRankArray];
        c.cellClass = WyCollectionViewCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            WyCollectionViewCell *cc = (WyCollectionViewCell *)cell;
            cc.backgroundColor = UIColor.systemPinkColor;
            cc.titleLabel.textColor = UIColor.whiteColor;
            cc.titleLabel.text = (NSString *)itemID;
        };

        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"rank_array"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    // 1) 同一种水平滚动书架：仅尺寸不同（无需创建新的 Section 子类）
    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleHorizontal];
        c.itemSize = CGSizeMake(88, 88);
        c.cellClass = WyCollectionViewCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            WyCollectionViewCell *cc = (WyCollectionViewCell *)cell;
            cc.backgroundColor = UIColor.systemPinkColor;
            cc.titleLabel.textColor = UIColor.whiteColor;
            cc.titleLabel.text = (NSString *)itemID;
        };
        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"hor_text_small"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleHorizontal];
        c.itemSize = CGSizeMake(160, 120);
        c.cellClass = WyCollectionViewCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            WyCollectionViewCell *cc = (WyCollectionViewCell *)cell;
            cc.backgroundColor = UIColor.systemPinkColor;
            cc.titleLabel.textColor = UIColor.whiteColor;
            cc.titleLabel.text = (NSString *)itemID;
        };
        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"hor_text_large"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    // 2) 同为水平滚动，但用不同 cell（同样无需 subclass）
    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleHorizontal];
        c.itemSize = CGSizeMake(120, 100);
        c.cellClass = WaterfallCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            [(WaterfallCell *)cell configureWithText:(NSString *)itemID];
        };
        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"hor_waterfall_cell"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    // 3) 竖向网格：3 列
    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleGrid];
        c.numberOfColumns = 3;
        c.itemSize = CGSizeMake(0, 100);
        c.cellClass = WyCollectionViewCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            WyCollectionViewCell *cc = (WyCollectionViewCell *)cell;
            cc.backgroundColor = UIColor.systemIndigoColor;
            cc.titleLabel.textColor = UIColor.whiteColor;
            cc.titleLabel.text = (NSString *)itemID;
        };
        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"grid_3col"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    // 4) 复刻：Waterfall（generateWaterfallSectionWithEnvironment）
    {
        WyCompositionalListShelfConfiguration *c =
        [WyCompositionalListShelfConfiguration defaultConfigurationWithStyle:WyCompositionalListShelfLayoutStyleWaterfall];
        c.cellClass = WaterfallCell.class;
        c.configureCell = ^(UICollectionViewCell *cell, id<NSCopying> itemID, NSIndexPath *indexPath) {
            [(WaterfallCell *)cell configureWithText:(NSString *)itemID];
        };
        [sections addObject:[[WyCompositionalListShelfSection alloc] initWithSectionID:@"waterfall"
                                                                          dataProvider:pageVM
                                                                         configuration:c]];
    }

    return sections;
}

@end

