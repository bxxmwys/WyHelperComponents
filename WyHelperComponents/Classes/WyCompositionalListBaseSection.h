//
//  WyCompositionalListBaseSection.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WyCompositionalListSection.h"
#import "WyCompositionalListSectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 可二次继承的 Section 基类：
/// - 默认从 viewModel 提供 sectionID / itemIDs
/// - 子类只需关注：layout + 注册 + cell 配置（或继续封装模板）
@interface WyCompositionalListBaseSection : NSObject <WyCompositionalListSection>

@property (nonatomic, strong, readonly) id<WyCompositionalListSectionViewModel> viewModel;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithViewModel:(id<WyCompositionalListSectionViewModel>)viewModel NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

