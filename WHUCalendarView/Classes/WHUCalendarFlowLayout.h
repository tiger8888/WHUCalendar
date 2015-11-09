//
//  WHUCalendarFlowLayout.h
//  TEST_Calendar
//
//  Created by SuperNova on 15/11/5.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHUCalendarFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, assign) NSInteger dataCount;
@property(nonatomic,assign) CGFloat conHeight;
@end
