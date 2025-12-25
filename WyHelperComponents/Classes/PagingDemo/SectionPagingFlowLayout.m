//
//  SectionPagingFlowLayout.m
//  WyHelperComponents
//
//  Created by yansheng wei on 2025/1/3.
//

#import "SectionPagingFlowLayout.h"

@implementation SectionPagingFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
    }
    return self;
}

@end


