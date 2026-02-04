//
//  WyCompositionalListShelfSection.h
//  WyHelperComponents
//
//  Created by GPT on 2026/2/3.
//

#import "WyCompositionalListSection.h"
#import "WyCompositionalListSectionDataProvider.h"
#import "WyCompositionalListShelfConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// 通用书架 Section（核心优化点）：
/// - 绝大多数书架不需要创建新的 Section 子类
/// - 用 configuration 描述样式差异（滚动方式/尺寸/列数/间距/header/footer/cell）
/// - 用 pageVM(dataProvider) 按 sectionID 提供数据
@interface WyCompositionalListShelfSection : NSObject <WyCompositionalListSection>

@property (nonatomic, copy, readonly) NSString *sectionID;
@property (nonatomic, strong, readonly) id<WyCompositionalListSectionDataProvider> dataProvider;
@property (nonatomic, strong, readonly) WyCompositionalListShelfConfiguration *configuration;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithSectionID:(NSString *)sectionID
                     dataProvider:(id<WyCompositionalListSectionDataProvider>)dataProvider
                    configuration:(WyCompositionalListShelfConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

