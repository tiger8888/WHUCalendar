//
//  WHUCalendarCell.h
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/5.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHUCalendarCell : UICollectionViewCell
@property(nonatomic,strong) UILabel* lbl;
@property(nonatomic,strong) UILabel* dbl;
@property(nonatomic,assign) BOOL isToday;
@property(nonatomic,assign) BOOL isDayInCurMonth;
@property(nonatomic,assign) NSInteger rowIndex;
@property(nonatomic,assign) NSInteger total;
@end
