//
//  ViewController.m
//  WHUCalendarView
//
//  Created by SuperNova(QQ:422596694) on 15/11/9.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "ViewController.h"
#import "WHUCalendarPopView.h"
@interface ViewController ()
{
    WHUCalendarPopView* _pop;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
