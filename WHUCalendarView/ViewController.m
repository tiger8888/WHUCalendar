//
//  ViewController.m
//  WHUCalendarView
//
//  Created by SuperNova(QQ:422596694) on 15/11/9.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "ViewController.h"
#import "WHUCalendarPopView.h"
#import "WHUCalendarView.h"
@interface ViewController ()
{
    WHUCalendarPopView* _pop;
}
@property (weak, nonatomic) IBOutlet WHUCalendarView *calview;
@end

@implementation ViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
