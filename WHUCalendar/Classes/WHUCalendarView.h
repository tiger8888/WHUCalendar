//
//  WHUCalendarView.h
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/5.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHUCalendarView : UIView
//用户选择的日期.
@property(nonatomic,strong,readonly)  NSDate* selectedDate;
//用户选择日期后的操作.
@property(nonatomic,strong) void(^onDateSelectBlk)(NSDate*);
//当前日历的显示月份,默认显示为当前月份的日历.
@property(nonatomic,strong) NSDate* currentDate;
@property(nonatomic,strong) BOOL(^canSelectDate)(NSDate*);
//calMonth存放的当前日历的年,月, itemDate存放单个日期的年,月,日
@property(nonatomic,strong) NSString*(^tagStringOfDate)(NSArray* calMonth,NSArray* itemDate);
@end
