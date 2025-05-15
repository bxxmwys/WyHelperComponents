//
//  WyAccountModel.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/4/11.
//

#import "WyAccountModel.h"
#import "WyAccountModel+WCTTableCoding.h"

@implementation WyAccountModel

WCDB_IMPLEMENTATION(WyAccountModel)
WCDB_SYNTHESIZE(book_id)
WCDB_SYNTHESIZE(book_pic)
WCDB_SYNTHESIZE(chapter_count)

// 约束宏定义数据库的主键
WCDB_PRIMARY(book_id)


@end
