//
//  WyCompositionalListShelfConfiguration.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import "WyCompositionalListShelfConfiguration.h"

@class WyCollectionReusableView;

@implementation WyCompositionalListShelfConfiguration

+ (instancetype)defaultConfigurationWithStyle:(WyCompositionalListShelfLayoutStyle)style {
    WyCompositionalListShelfConfiguration *c = [WyCompositionalListShelfConfiguration new];
    c.layoutStyle = style;

    // 通用默认值
    c.contentInsets = NSDirectionalEdgeInsetsMake(0, 16, 0, 16);
    c.interGroupSpacing = 10.0;
    c.interItemSpacing = 10.0;
    c.headerHeight = 40.0;
    c.footerHeight = 0.0;
    c.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorNone;
    c.numberOfColumns = 3;
    c.rankArrayGroupHeight = 307.0;
    c.itemSize = CGSizeMake(98, 100);
    c.cellClass = UICollectionViewCell.class;
    c.headerElementKind = UICollectionElementKindSectionHeader;
    c.footerElementKind = UICollectionElementKindSectionFooter;
    c.headerViewClass = NSClassFromString(@"WyCollectionReusableView") ?: UICollectionReusableView.class;
    c.footerViewClass = NSClassFromString(@"WyCollectionReusableView") ?: UICollectionReusableView.class;
    c.configureCell = ^(UICollectionViewCell * _Nonnull cell, id<NSCopying>  _Nonnull itemID, NSIndexPath * _Nonnull indexPath) {
        // 默认不配置，由业务覆写
    };

    switch (style) {
        case WyCompositionalListShelfLayoutStyleRankArray: {
            c.itemSize = CGSizeMake(213, 100);
            c.interItemSpacing = 3.5;
            c.headerHeight = 100;
            c.footerHeight = 100;
            c.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;
        } break;
        case WyCompositionalListShelfLayoutStyleHorizontal: {
            c.itemSize = CGSizeMake(98, 100);
            c.headerHeight = 40;
            c.footerHeight = 0;
            c.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging;
        } break;
        case WyCompositionalListShelfLayoutStyleGrid: {
            c.numberOfColumns = 3;
            c.itemSize = CGSizeMake(0, 100); // width 自动按列数计算
            c.headerHeight = 40;
            c.footerHeight = 0;
        } break;
        case WyCompositionalListShelfLayoutStyleWaterfall: {
            c.numberOfColumns = 2;
            c.contentInsets = NSDirectionalEdgeInsetsMake(0, 20, 0, 20);
            c.interItemSpacing = 10;
            c.interGroupSpacing = 10;
            c.headerHeight = 40;
            c.footerHeight = 40;
        } break;
    }

    return c;
}

@end

