//
//  WyCompositionalListDemoSimpleVM.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoSimpleVM.h"

@interface WyCompositionalListDemoSimpleVM ()
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, copy) NSArray<id<NSCopying>> *itemIDs;
@property (nonatomic, copy, nullable) NSString *headerTitle;
@property (nonatomic, copy, nullable) NSString *footerTitle;
@end

@implementation WyCompositionalListDemoSimpleVM

- (instancetype)initWithSectionID:(NSString *)sectionID
                          header:(nullable NSString *)header
                          footer:(nullable NSString *)footer
                         itemIDs:(NSArray<id<NSCopying>> *)itemIDs {
    self = [super init];
    if (self) {
        _sectionID = [sectionID copy];
        _headerTitle = [header copy];
        _footerTitle = [footer copy];
        _itemIDs = [itemIDs copy] ?: @[];
    }
    return self;
}

@end

