//
//  WHUCalDrawView.h
//  Created by SuperNova on 16/4/3.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHUCalendarCal.h"
@interface WHUCalDrawView : UIView
@property(nonatomic,strong) UIColor* bgColor;
@property(nonatomic,strong) NSDictionary* dataDic;
@property(nonatomic,strong) NSDate* currentMonthDate;
@property(nonatomic,strong,readonly)  NSDate* selectedDate;//用户选择的日期.
@property(nonatomic,strong) void(^onDateSelectBlk)(NSDate* dateItem);
@property(nonatomic,strong) BOOL(^canSelectDate)(NSDate* dateItem);
@property(nonatomic,strong) NSString*(^tagStringOfDate)(NSArray* calMonth,NSArray* itemDate);
@property(nonatomic,strong) WHUCalendarCal* calcal;
-(void)reloadData;
@end
