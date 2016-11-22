//
//  WHUCalendarYMSelectView.m
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/6.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//
#import "WHUCalendarYMSelectView.h"
#define WHUCalendarYMSelectView_Piker_Height 150.0f
#define WHUCalendarYMSelectView_Margin 10.0f
@interface WHUCalendarYMSelectView()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,strong) UIPickerView* pickerView;
@property(nonatomic,strong) NSArray* monthArr;
@property(nonatomic,strong) NSArray* yearArr;
@property(nonatomic,assign) NSInteger curYear;
@property(nonatomic,assign) NSInteger yearRange;
@end
@implementation WHUCalendarYMSelectView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
   self= [super initWithCoder:aDecoder];
    if(self){
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    _yearRange=100;
    _pickerView=[[UIPickerView alloc] init];
    _pickerView.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:_pickerView];
    _pickerView.showsSelectionIndicator=YES;
    _pickerView.delegate=self;
    NSDictionary* viewDic=@{
                            @"picker":_pickerView
                            };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[picker]|" options:0 metrics:nil views:viewDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[picker]|" options:0 metrics:nil views:viewDic]];
    NSCalendar* cal=[NSCalendar currentCalendar];
    NSDateComponents* com=[cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    self.curYear=com.year;
    [_pickerView selectRow:_yearRange inComponent:0 animated:NO];
    [_pickerView selectRow:com.month-1 inComponent:1 animated:NO];
}


-(NSString*)selectdDateStr{
  NSInteger year=2015-_yearRange+[_pickerView selectedRowInComponent:0];
  NSInteger month=[_pickerView selectedRowInComponent:1]+1;
  return [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _yearRange*2+1;
    }
    
    return 12;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(component==0){
        return pickerView.frame.size.width/2.0f;
    }
    else{
        return pickerView.frame.size.width/3.0f;
    }
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        row=2015-_yearRange+row;
        return  [NSString stringWithFormat:@"%ld年",(long)row];
    } else {
        return  [NSString stringWithFormat:@"%ld月",(long)row+1];
    }
}
@end
