//
//  WyCompositionalListDemoHorizontalBaseSection.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/2.
//

#import "WyCompositionalListHorizontalTemplateSection.h"

NS_ASSUME_NONNULL_BEGIN

/// Demo：在模板 Section 基础上再封一层，统一 header/footer（演示“开发者可再次继承模板 Section”）
@interface WyCompositionalListDemoHorizontalBaseSection : WyCompositionalListHorizontalTemplateSection

/// header/footer 高度（默认 header=40, footer=0）
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

@end

NS_ASSUME_NONNULL_END

