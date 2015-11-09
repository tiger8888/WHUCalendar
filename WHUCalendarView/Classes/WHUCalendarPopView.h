//
//  WHUCalendarPopView.h
//  TEST_Calendar
//
//  Created by SuperNova on 15/11/7.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHUCalendarPopView : UIWindow
@property(nonatomic,strong) void(^onDateSelectBlk)(NSDate*);
-(void)dismiss;
-(void)show;
@end
