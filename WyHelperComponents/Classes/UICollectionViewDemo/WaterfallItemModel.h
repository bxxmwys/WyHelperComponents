//
//  WaterfallItemModel.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaterfallItemModel : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) NSInteger columnIndex;
@end

NS_ASSUME_NONNULL_END
