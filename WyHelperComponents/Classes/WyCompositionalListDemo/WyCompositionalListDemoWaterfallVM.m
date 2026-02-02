//
//  WyCompositionalListDemoWaterfallVM.m
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListDemoWaterfallVM.h"

@interface WyCompositionalListDemoWaterfallVM ()
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, copy) NSArray<id<NSCopying>> *itemIDs;
@property (nonatomic, copy, nullable) NSString *headerTitle;
@property (nonatomic, copy, nullable) NSString *footerTitle;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *heightByID;
@end

@implementation WyCompositionalListDemoWaterfallVM

- (instancetype)initWithSectionID:(NSString *)sectionID
                           header:(nullable NSString *)header
                           footer:(nullable NSString *)footer
                          itemIDs:(NSArray<NSString *> *)itemIDs
                       heightByID:(NSDictionary<NSString *, NSNumber *> *)heightByID {
    self = [super init];
    if (self) {
        _sectionID = [sectionID copy];
        _headerTitle = [header copy];
        _footerTitle = [footer copy];
        _itemIDs = [itemIDs copy] ?: @[];
        _heightByID = [heightByID copy] ?: @{};
    }
    return self;
}

- (CGFloat)heightForItemID:(NSString *)itemID {
    return self.heightByID[itemID].doubleValue;
}

@end

