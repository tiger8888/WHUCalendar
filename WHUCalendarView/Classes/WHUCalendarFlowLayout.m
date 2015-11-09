//
//  WHUCalendarFlowLayout.m
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/5.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "WHUCalendarFlowLayout.h"
#define WHUCalendarFlowLayout_MaxCount 42
@interface WHUCalendarFlowLayout()
// 所有item的属性的数组
@property (nonatomic, strong) NSArray *layoutAttributesArray;
@property(nonatomic,assign) CGFloat itemWidth;
@property(nonatomic,strong) NSMutableDictionary* posDic;
@end
@implementation WHUCalendarFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 直接返回计算好的布局属性数组
    return [self.layoutAttributesArray subarrayWithRange:NSMakeRange(0, _dataCount)];
}


- (void)prepareLayout {
    if(self.layoutAttributesArray==nil){
        NSInteger index = 0;
        NSMutableArray *attributesArray = [NSMutableArray arrayWithCapacity:WHUCalendarFlowLayout_MaxCount];
        NSInteger total=WHUCalendarFlowLayout_MaxCount;
        for (int i=0;i<total;i++) {
            // 建立布局属性
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            // 设置frame
            CGFloat itemX=(index%7)*self.itemSize.width;
            CGFloat itemY=(index/7)*self.itemSize.height;
            attributes.frame = CGRectMake(itemX, itemY, self.itemSize.width, self.itemSize.height);
            [attributesArray addObject:attributes];
            index++;
            _conHeight=itemY;
        }
        self.conHeight+=self.itemSize.height;
        self.layoutAttributesArray = attributesArray.copy;
    }

}

@end
