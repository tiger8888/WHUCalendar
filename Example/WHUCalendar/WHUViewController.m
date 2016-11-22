//
//  WHUViewController.m
//  WHUCalendar
//
//  Created by tiger8888 on 11/22/2016.
//  Copyright (c) 2016 tiger8888. All rights reserved.
//

#import "WHUViewController.h"
#import "WHUCalendarPopView.h"
#import "WHUCalendarView.h"
@interface WHUViewController ()
{
    WHUCalendarPopView* _pop;
}
@property (weak, nonatomic) IBOutlet WHUCalendarView *calview;
@end

@implementation WHUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _calview.tagStringOfDate=^NSString*(NSArray* calm,NSArray* itemDateArray){
        NSLog(@"%@",calm);
        //如果当前日期中的天数,可以被5整除,显示 预约
        if([itemDateArray[2] integerValue]%5==0){
            return @"预约";
        }
        else{
            return nil;
        }
    };
    
    _calview.onDateSelectBlk=^(NSDate* date){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy年MM月dd"];
        NSString *dateString = [format stringFromDate:date];
        NSLog(@"calview:%@",dateString);
    };
    
    _pop=[[WHUCalendarPopView alloc] init];
    _pop.onDateSelectBlk=^(NSDate* date){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy年MM月dd"];
        NSString *dateString = [format stringFromDate:date];
        NSLog(@"%@",dateString);
    };
}
- (IBAction)onBtnClick:(id)sender {
    [_pop show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
