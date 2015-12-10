//
//  WHUCalendarPopView.m
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/7.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "WHUCalendarPopView.h"
#import "WHUCalendarView.h"
#import "WHUCalendarMarcro.h"
@interface WHUCalendarPopView()
@property(nonatomic,strong) UIButton* backBtn;
@property(nonatomic,strong) WHUCalendarView* calView;
@property(nonatomic,strong) NSLayoutConstraint* bottomGapCts;
@property(nonatomic,assign) CGFloat calHeight;
@end

@implementation WHUCalendarPopView
-(id)initWithFrame:(CGRect)frame{
    CGRect screenBounds=[[UIScreen mainScreen] bounds];
    self=[super initWithFrame:screenBounds];
    if(self){
        _calView=[[WHUCalendarView alloc] init];
        _calView.translatesAutoresizingMaskIntoConstraints=NO;
        _backBtn=[UIButton  buttonWithType:UIButtonTypeCustom];
        _backBtn.frame=screenBounds;
        [_backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backBtn];
        _backBtn.backgroundColor=[UIColor clearColor];
        CGSize s=[_calView sizeThatFits:CGSizeMake(screenBounds.size.width, FLT_MAX)];
        _calHeight=s.height;
        [self addSubview:_calView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_calView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_calView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:s.height+10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_calView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        _bottomGapCts=[NSLayoutConstraint constraintWithItem:_calView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:s.height];
        [self addConstraint:_bottomGapCts];
        WHUCalendarView_WeakSelf weakself=self;
        _calView.onDateSelectBlk=^(NSDate* date){
            WHUCalendarView_StrongSelf self=weakself;
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
            dispatch_after(time, dispatch_get_main_queue(), ^{
            [self dismiss];
            });
        };
    }
    return self;
}

-(void)setOnDateSelectBlk:(void (^)(NSDate *))onDateSelectBlk{
    _onDateSelectBlk=onDateSelectBlk;
    WHUCalendarView_WeakSelf weakself=self;
    if(onDateSelectBlk!=nil){
        WHUCalendarView_StrongSelf self=weakself;
        self->_calView.onDateSelectBlk=^(NSDate* date){
            WHUCalendarView_StrongSelf self=weakself;
            onDateSelectBlk(date);
            [self dismiss];
        };
    }
}


-(void)show{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    self.hidden=NO;
    _bottomGapCts.constant=0;
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:nil];
}


-(void)dismiss{
    _bottomGapCts.constant=_calHeight;
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL b){
        self.hidden=YES;
    }];
}
@end
