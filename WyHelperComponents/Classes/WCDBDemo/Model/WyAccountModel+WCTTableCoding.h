//
//  WyAccountModel+WCTTableCoding.h
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/4/11.
//

#import "WyAccountModel.h"
#import <WCDBObjc/WCDBObjc.h>

@interface WyAccountModel (WCTTableCoding)<WCTTableCoding>

WCDB_PROPERTY(book_id)
WCDB_PROPERTY(book_pic)
WCDB_PROPERTY(chapter_count)

@end
