//
//  WyCompositionalListDemoHorizontalTextSection.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoHorizontalTextSection.h"

#import "WyCollectionViewCell.h"

@implementation WyCompositionalListDemoHorizontalTextSection

- (Class)cellClass {
    return WyCollectionViewCell.class;
}

- (void)configureCell:(UICollectionViewCell *)cell itemID:(id<NSCopying>)itemID indexPath:(NSIndexPath *)indexPath {
    WyCollectionViewCell *c = (WyCollectionViewCell *)cell;
    c.backgroundColor = UIColor.systemPinkColor;
    c.titleLabel.textColor = UIColor.whiteColor;
    c.titleLabel.text = (NSString *)itemID;
}

@end

