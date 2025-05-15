//
//  WyAccountModel.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/4/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WyAccountModel : NSObject

/// story id
@property (nonatomic, copy) NSString *book_id;

@property (nonatomic, copy) NSString *book_pic;
/// 总的集数
@property (nonatomic, assign) NSInteger chapter_count;

@end

NS_ASSUME_NONNULL_END
