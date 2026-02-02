//
//  WyCompositionalListDemoSimpleVM.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <Foundation/Foundation.h>

#import "WyCompositionalListSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WyCompositionalListDemoSimpleVM : NSObject <WyCompositionalListSectionViewModel>

- (instancetype)initWithSectionID:(NSString *)sectionID
                          header:(nullable NSString *)header
                          footer:(nullable NSString *)footer
                         itemIDs:(NSArray<id<NSCopying>> *)itemIDs NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

