//
//  WyCompositionalListDemoHorizontalWaterfallCellSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoHorizontalWaterfallCellSection.h"

#import "WaterfallCell.h"

@implementation WyCompositionalListDemoHorizontalWaterfallCellSection

- (Class)cellClass {
    return WaterfallCell.class;
}

- (void)configureCell:(UICollectionViewCell *)cell itemID:(id<NSCopying>)itemID indexPath:(NSIndexPath *)indexPath {
    WaterfallCell *c = (WaterfallCell *)cell;
    [c configureWithText:(NSString *)itemID];
}

@end

