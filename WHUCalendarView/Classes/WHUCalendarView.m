//
//  WHUCalendarView.m
//  TEST_Calendar
//
//  Created by SuperNova on 15/11/5.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "WHUCalendarView.h"
#import "WHUCalendarCell.h"
#import "WHUCalendarItem.h"
#import "WHUCalendarCal.h"
#import "WHUCalendarFlowLayout.h"
#import "WHUCalendarYMSelectView.h"
#import "WHUCalendarMarcro.h"
#define WHUCalendarView_TopView_Height 35.0f
#define WHUCalendarView_WeekView_Height 20.0f
#define WHUCalendarView_ContentView_Height 250.0f
#define WHUCalendarView_Margin_Horizon 15.0f
typedef NS_ENUM(NSUInteger, WHUCalendarViewMonthOption) {
    WHUCalendarViewPreMonth,
    WHUCalendarViewNextMonth
};
@interface WHUCalendarView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UIView* _topView;
    UIView* _weekView;
    UIView* _contentView;
    UIView* _calendarConView;
    
    UIButton* _mLeftBtn;
    UIButton* _mRightBtn;
    
    UIButton* _yLeftBtn;
    UIButton* _yRightBtn;
    
    UICollectionView* _calView;
    UILabel* _curMonthLbl;
    
    NSArray* _dataArr;
    NSDictionary* _dataDic;
    WHUCalendarCal* _calcal;
    UITapGestureRecognizer* _collectionTapGes;
    UIPanGestureRecognizer* _collectionPanGes;
    WHUCalendarYMSelectView* _pickerView;
    
    NSLayoutConstraint* _calviewBottomGapCts;
    
    NSString* _selectedDateString;
    
    CGFloat _screenScale;
    BOOL _shouldLayout;
}

@end
@implementation WHUCalendarView
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        [self setupView];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}


-(void)setupView{
    _shouldLayout=YES;
    _calcal=[[WHUCalendarCal alloc] init];
    //预加载下数据
    _topView=[self makeView];
    _weekView=[self makeView];
    _contentView=[self makeView];
    [self addSubview:_topView];
    
    WHUCalendarYMSelectView* selView=[[WHUCalendarYMSelectView alloc] init];
    selView.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:selView];
    _pickerView=selView;
    _pickerView.hidden=YES;
    UIView* calendarConView=[[UIView alloc] init];
    [self addSubview:calendarConView];
    calendarConView.translatesAutoresizingMaskIntoConstraints=NO;
    [calendarConView addSubview:_weekView];
    [calendarConView addSubview:_contentView];
    _calendarConView=calendarConView;
    UIColor* bgColor=[UIColor colorWithRed:0.93 green:0.92 blue:0.95 alpha:1];
    _topView.backgroundColor=bgColor;
    _weekView.backgroundColor=bgColor;
    _contentView.backgroundColor=bgColor;
    self.backgroundColor=bgColor;
    NSDictionary* viewDic=@{@"topv":_topView,@"midv":_weekView,@"bottomv":_contentView,@"calcon":calendarConView,@"selview":selView};
    NSDictionary* metrics=@{@"topH":@(WHUCalendarView_TopView_Height),
                            @"midH":@(WHUCalendarView_WeekView_Height)
                            };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==10)-[selview]-(==10)-|" options:0 metrics:nil views:viewDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topv]-(==-10)-[selview(==162)]" options:0 metrics:nil views:viewDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topv]|" options:0 metrics:nil views:viewDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[calcon]|" options:0 metrics:nil views:viewDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topv(==topH)][calcon]|" options:0 metrics:metrics views:viewDic]];
    [calendarConView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[midv]|" options:0 metrics:nil views:viewDic]];
    [calendarConView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomv]|" options:0 metrics:nil views:viewDic]];
    [calendarConView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[midv(==midH)][bottomv]|" options:0 metrics:metrics views:viewDic]];
    
    
    
    UIButton* preBtn=[self makeButtonWithText:@"上一月"];
    preBtn.translatesAutoresizingMaskIntoConstraints=NO;
    _mLeftBtn=preBtn;
    preBtn.tag=1000;
    [preBtn addTarget:self action:@selector(monthSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    UIButton* nextBtn=[self makeButtonWithText:@"下一月"];
    _mRightBtn=nextBtn;
    nextBtn.tag=2000;
    nextBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [nextBtn addTarget:self action:@selector(monthSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    UILabel* curDateLbl=[[UILabel alloc] init];
    curDateLbl.font=[UIFont boldSystemFontOfSize:18.0f];
    curDateLbl.translatesAutoresizingMaskIntoConstraints=NO;
    curDateLbl.text=@"            ";
    _curMonthLbl=curDateLbl;
    _curMonthLbl.userInteractionEnabled=YES;
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired=1;
    [_curMonthLbl addGestureRecognizer:tap];
    [curDateLbl sizeToFit];
    [_topView addSubview:preBtn];
    [_topView addSubview:nextBtn];
    [_topView addSubview:curDateLbl];
    NSDictionary* viewDic2=@{@"prebtn":preBtn,@"nextbtn":nextBtn};
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[prebtn]|" options:0 metrics:nil views:viewDic2]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[prebtn(==80)]" options:0 metrics:nil views:viewDic2]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nextbtn]|" options:0 metrics:nil views:viewDic2]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[nextbtn(==80)]|" options:0 metrics:nil views:viewDic2]];
    
    
    [_topView addConstraint:[NSLayoutConstraint constraintWithItem:curDateLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    [_topView addConstraint:[NSLayoutConstraint constraintWithItem:curDateLbl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    
}

-(void)setCurrentDate:(NSDate *)currentDate{
    _currentDate=currentDate;
    if(_currentDate!=nil){
        if(_weekView.subviews.count>0){
        WHUCalendarView_WeakSelf weakSelf=self;
        [_calcal getCalendarMapWith:_pickerView.selectdDateStr completion:^(NSDictionary* dic){
            WHUCalendarView_StrongSelf self=weakSelf;
            self->_dataDic=dic;
            [self reloadCollectionView];
            self->_curMonthLbl.text=_dataDic[@"monthStr"];
            self->_calView.hidden=YES;
            [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self->_calView.hidden=NO;
            } completion:nil];
        }];
        }
        else{
            _dataDic=[_calcal loadDataWith:[_calcal stringFromDate:_currentDate]];
        }
    }
}

-(void)toggleBtnState:(void(^)(void))complitionBlk{
    if(_mLeftBtn.hidden){
        _curMonthLbl.text=_dataDic[@"monthStr"];
        _yLeftBtn.hidden=YES;
        _yRightBtn.hidden=YES;
        _mLeftBtn.hidden=NO;
        _mRightBtn.hidden=NO;
        [CATransaction begin];
        CATransform3D trans=CATransform3DIdentity;
        trans.m34=-1.0/500.0;
        trans=CATransform3DTranslate(trans, 0, 45, 0);
        trans=CATransform3DRotate(trans, -M_PI/2.8, 1, 0,0);
        trans=CATransform3DScale(trans, 0.8, 0.8, 0.8);
        _calendarConView.layer.transform=CATransform3DIdentity;
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        basicAnimation.fromValue=[NSValue valueWithCATransform3D:trans];
        basicAnimation.toValue =[NSValue  valueWithCATransform3D:CATransform3DIdentity];
        basicAnimation.duration = 0.3f;
        basicAnimation.cumulative = NO;
        basicAnimation.repeatCount = 0;
        [CATransaction setCompletionBlock:^{
            _pickerView.hidden=YES;
            if(complitionBlk!=nil){
                complitionBlk();
            }
        }];
        
        //   basicAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5:0:0.9:0.7];
        [_calendarConView.layer addAnimation:basicAnimation forKey:nil];
        [CATransaction commit];
        [ _calendarConView removeGestureRecognizer:_collectionTapGes];
        [_calendarConView removeGestureRecognizer:_collectionPanGes];
        _collectionTapGes=nil;
        _collectionPanGes=nil;
        _calView.userInteractionEnabled=YES;
        for(UIGestureRecognizer* ges in _calendarConView.gestureRecognizers){
            if([ges isKindOfClass:[UISwipeGestureRecognizer class]]){
                ges.enabled=YES;
            }
        }
        _collectionPanGes.enabled=NO;
        _collectionTapGes.enabled=NO;
    }
    else{
        _pickerView.hidden=NO;
        _curMonthLbl.text=@"选择年份月份";
        _yLeftBtn.hidden=NO;
        _yRightBtn.hidden=NO;
        _mLeftBtn.hidden=YES;
        _mRightBtn.hidden=YES;
        _calView.userInteractionEnabled=NO;
        CATransform3D trans=CATransform3DIdentity;
        trans.m34=-1.0/500.0;
        trans=CATransform3DTranslate(trans, 0, 45, 0);
        trans=CATransform3DRotate(trans, -M_PI/2.8, 1, 0,0);
        trans=CATransform3DScale(trans, 0.8, 0.8, 0.8);
        _calendarConView.layer.transform=trans;
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        basicAnimation.fromValue=[NSValue  valueWithCATransform3D:CATransform3DIdentity];
        basicAnimation.toValue = [NSValue valueWithCATransform3D:trans];
        basicAnimation.duration = 0.3f;
        basicAnimation.cumulative = NO;
        basicAnimation.repeatCount = 0;
        for(UIGestureRecognizer* ges in _calendarConView.gestureRecognizers){
            if([ges isKindOfClass:[UISwipeGestureRecognizer class]]){
                ges.enabled=NO;
            }
        }
        if(_collectionTapGes==nil||_collectionPanGes==nil){
            [_calendarConView.layer addAnimation:basicAnimation forKey:nil];
            _collectionTapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [_calendarConView addGestureRecognizer:_collectionTapGes];
            _collectionPanGes=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
            [_collectionTapGes requireGestureRecognizerToFail:_collectionPanGes];
            [_calendarConView addGestureRecognizer:_collectionPanGes];
        }
        _collectionPanGes.enabled=YES;
        _collectionTapGes.enabled=YES;
    }
}

-(void)panAction:(UIPanGestureRecognizer*)pan{
    if(pan.state==UIGestureRecognizerStateBegan){
        [self toggleBtnState:nil];
    }
}

-(void)tapAction:(UITapGestureRecognizer*)tap{
    [self toggleBtnState:nil];
}

-(void)reloadCollectionView{
    NSArray* tempArr=_dataDic[@"dataArr"];
    WHUCalendarFlowLayout* layout=(WHUCalendarFlowLayout*)_calView.collectionViewLayout;
    layout.dataCount=tempArr.count;
    [_calView reloadData];
    NSInteger row=-1;
    for(int i=0;i<tempArr.count;i++){
            WHUCalendarItem* item=tempArr[i];
            if([item.dateStr isEqualToString:_selectedDateString]){
                row=i;
                break;
            }
    }
    _calviewBottomGapCts.constant=[self getCollectionContentHeight]-_contentView.bounds.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(row>0){
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            [_calView selectItemAtIndexPath:indexPath animated:NO scrollPosition:0];
        }
    });
}

-(void)monthSelectAction:(UIButton*)sender{
    if(sender.tag==1000){
        [self loadCalendarDataFor:WHUCalendarViewPreMonth];
    }
    else{
        [self loadCalendarDataFor:WHUCalendarViewNextMonth];
    }
}

-(void)yearMonthSelectAction:(UIButton*)btn{
    if(btn.tag==4000){
        [self toggleBtnState:^{
            WHUCalendarView_WeakSelf weakself=self;
            [_calcal getCalendarMapWith:_pickerView.selectdDateStr completion:^(NSDictionary* dic){
                WHUCalendarView_StrongSelf self=weakself;
                self->_dataDic=dic;
                [self reloadCollectionView];
                self->_curMonthLbl.text=self->_dataDic[@"monthStr"];
                self->_calView.hidden=YES;
                [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self->_calView.hidden=NO;
                } completion:nil];
            }];
        }];
    }
    else{
        [self toggleBtnState:nil];
    }
}

-(void)loadCalendarDataFor:(WHUCalendarViewMonthOption )option{
    WHUCalendarView_WeakSelf weakself=self;
    if(option==WHUCalendarViewPreMonth){
        [_calcal preMonthCalendar:_curMonthLbl.text complete:^(NSDictionary* dic){
            WHUCalendarView_StrongSelf self=weakself;
            self->_dataDic=dic;
            CATransition* tran=[CATransition animation];
            self->_curMonthLbl.text=dic[@"monthStr"];
            tran.duration=0.3;
            tran.type=kCATransitionFade;
            [self->_curMonthLbl.layer addAnimation:tran forKey:nil];
            [self reloadCollectionView];
        }];
    }
    else if( option==WHUCalendarViewNextMonth){
        
        [_calcal nextMonthCalendar:_curMonthLbl.text complete:^(NSDictionary* dic){
            WHUCalendarView_StrongSelf self=weakself;
            self->_dataDic=dic;
            CATransition* tran=[CATransition animation];
            self->_curMonthLbl.text=dic[@"monthStr"];
            tran.duration=0.3;
            tran.type=kCATransitionFade;
            [self->_curMonthLbl.layer addAnimation:tran forKey:nil];
            [self reloadCollectionView];
        }];
    }
}


-(void)swipeAction:(UISwipeGestureRecognizer*)swipe{
    if(swipe.direction==UISwipeGestureRecognizerDirectionDown){
        [self tapAction:nil];
    }
    else {
        if(swipe.direction==UISwipeGestureRecognizerDirectionLeft){
            [self loadCalendarDataFor:WHUCalendarViewPreMonth];
        }
        else if(swipe.direction==UISwipeGestureRecognizerDirectionRight){
            [self loadCalendarDataFor:WHUCalendarViewNextMonth];
        }
    }
}

-(CGSize)getCollectionCellItemSize{
    CGFloat itemWidth=(self.bounds.size.width-WHUCalendarView_Margin_Horizon)/7.0f;
    return CGSizeMake(itemWidth, itemWidth);
}


-(CGFloat)getCollectionContentHeight{
    CGSize size=[self getCollectionCellItemSize];
    NSArray* tempArr=_dataDic[@"dataArr"];
    return size.height*(tempArr.count/7);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(_weekView.subviews.count==0){
        NSArray* weekArr=@[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
        UILabel* preLbl=nil;
        CGFloat weekMargin=WHUCalendarView_Margin_Horizon;
        NSString* firstStr=weekArr[0];
        CGRect strRect=[firstStr boundingRectWithSize:CGSizeMake(FLT_MAX, WHUCalendarView_WeekView_Height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:nil context:nil];
        CGFloat itemCount=(CGFloat)weekArr.count;
        CGFloat weekGap=(self.bounds.size.width-2*weekMargin-itemCount*strRect.size.width)/(itemCount-1);
        for(int i=0;i<weekArr.count;i++){
            UILabel* lbl=[[UILabel alloc] init];
            lbl.translatesAutoresizingMaskIntoConstraints=NO;
            lbl.font=[UIFont systemFontOfSize:12.0f];
            lbl.text=weekArr[i];
            lbl.textColor=[UIColor blackColor];
            [lbl sizeToFit];
            [_weekView addSubview:lbl];
            [_weekView addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_weekView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
            if(preLbl==nil){
                [_weekView addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_weekView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:weekMargin]];
            }
            else{
                [_weekView addConstraint:[NSLayoutConstraint constraintWithItem:lbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:preLbl attribute:NSLayoutAttributeRight multiplier:1.0f constant:weekGap]];
            }
            preLbl=lbl;
        }
        
        if(_dataDic==nil){
           _dataDic=[_calcal loadDataWith:[_calcal stringFromDate:[NSDate date]]];
            _curMonthLbl.text=_dataDic[@"monthStr"];
        }
        
        WHUCalendarFlowLayout* flowLayout = [[WHUCalendarFlowLayout alloc]init];
        CGSize itemSize=[self getCollectionCellItemSize];
        flowLayout.itemSize = itemSize;
        flowLayout.minimumLineSpacing=0;
        flowLayout.sectionInset=UIEdgeInsetsZero;
        flowLayout.minimumInteritemSpacing=0;
        flowLayout.headerReferenceSize=CGSizeZero;
        flowLayout.footerReferenceSize=CGSizeZero;
        _calView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        CGFloat w=1/([UIScreen mainScreen].scale);
        _calView.layer.borderColor=[UIColor lightGrayColor].CGColor;
        _calView.layer.borderWidth=w;
        _calView.allowsMultipleSelection=YES;
        _calView.delegate=self;
        _calView.dataSource=self;
        _calView.backgroundColor=[UIColor colorWithRed:0.93 green:0.92 blue:0.95 alpha:1];
        _calView.scrollEnabled=NO;
        [_calView registerClass:[WHUCalendarCell class] forCellWithReuseIdentifier:@"cell"];
        _calView.translatesAutoresizingMaskIntoConstraints=NO;
        NSDictionary* viewDic2=@{@"calview":_calView};
        NSDictionary* metrics2=@{@"gap":@(WHUCalendarView_Margin_Horizon/2.0f)};
        _contentView.layer.masksToBounds=YES;
        [_contentView addSubview:_calView];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==gap)-[calview]-(==gap)-|" options:0 metrics:metrics2 views:viewDic2]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[calview]" options:0 metrics:nil views:viewDic2]];
        _calviewBottomGapCts=[NSLayoutConstraint constraintWithItem:_calView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        [_contentView addConstraint:_calviewBottomGapCts];
        
        
        
        _curMonthLbl.text=_dataDic[@"monthStr"];
        NSArray* tempArr=_dataDic[@"dataArr"];
        flowLayout.dataCount=tempArr.count;
        flowLayout.columnCount=7;
        [_calView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UISwipeGestureRecognizer* swipeRight=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
            swipeRight.numberOfTouchesRequired=1;
            swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
            UISwipeGestureRecognizer* swipeLeft=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
            swipeLeft.numberOfTouchesRequired=1;
            swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
            UISwipeGestureRecognizer* swipeDown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
            swipeDown.numberOfTouchesRequired=1;
            swipeDown.direction=UISwipeGestureRecognizerDirectionDown;
            [_calendarConView addGestureRecognizer:swipeRight];
            [_calendarConView addGestureRecognizer:swipeLeft];
            [_calendarConView addGestureRecognizer:swipeDown];
            swipeRight.delaysTouchesBegan=YES;
            swipeLeft.delaysTouchesBegan=YES;
            swipeDown.delaysTouchesBegan=YES;
            for(UIGestureRecognizer* ges in _calView.gestureRecognizers){
                if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
                    [ges requireGestureRecognizerToFail:swipeRight];
                    [ges requireGestureRecognizerToFail:swipeLeft];
                    [ges requireGestureRecognizerToFail:swipeDown];
                }
            }
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
            _calviewBottomGapCts.constant=[self getCollectionContentHeight]-_contentView.bounds.size.height;
            UIButton* preBtn=[self makeButtonWithText:@"取消"];
            _yLeftBtn=preBtn;
            preBtn.tag=3000;
            [preBtn addTarget:self action:@selector(yearMonthSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            preBtn.frame=_mLeftBtn.frame;
            preBtn.hidden=YES;
            [_topView addSubview:preBtn];
            UIButton* nextBtn=[self makeButtonWithText:@"确定"];
            _yRightBtn=nextBtn;
            nextBtn.tag=4000;
            nextBtn.frame=_mRightBtn.frame;
            nextBtn.hidden=YES;
            [_topView addSubview:nextBtn];
            [nextBtn addTarget:self action:@selector(yearMonthSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat totalHeight=_contentView.frame.size.height;
            UILabel* info1=[[UILabel alloc] initWithFrame:CGRectMake(10, totalHeight-35, 300, 12)];
            info1.text=@"1.向左滑动,跳转到上一月,向右滑动,跳转到下一月.";
            info1.textColor=[UIColor lightGrayColor];
            info1.font=[UIFont systemFontOfSize:11.0f];
            UILabel* info2=[[UILabel alloc] initWithFrame:CGRectMake(10, totalHeight-18, 300, 12)];
            info2.text=@"2.向下滑动可以跳转到选择年份月份界面.";
            info2.textColor=[UIColor lightGrayColor];
            info2.font=[UIFont systemFontOfSize:11.0f];
            [_contentView addSubview:info1];
            [_contentView addSubview:info2];
            [_contentView sendSubviewToBack:info1];
            [_contentView sendSubviewToBack:info2];
        });
    }
}


-(UIButton*)makeButtonWithText:(NSString*)title{
    UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.bounds=CGRectMake(0, 0, 100, WHUCalendarView_TopView_Height);
    return btn;
}


-(UIView*)makeView{
    UIView* v=[[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints=NO;
    return v;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray* tempArr=_dataDic[@"dataArr"];
    return tempArr.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHUCalendarCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSArray* tempArr=_dataDic[@"dataArr"];
    cell.rowIndex=indexPath.row;
    cell.total=tempArr.count;
    WHUCalendarItem* item=tempArr[indexPath.row];
    if(item.holiday!=nil){
        cell.dbl.text=item.holiday;
    }
    else{
        cell.dbl.text=item.Chinese_calendar;
    }
    if([item.dateStr isEqualToString:[_calcal currentDateStr]]){
        cell.isToday=YES;
    }
    else{
        cell.isToday=NO;
    }
    
    if(item.day<0){
        cell.lbl.text=[NSString stringWithFormat:@"%ld",(long)-item.day];
        cell.lbl.textColor=[UIColor lightGrayColor];
        cell.isDayInCurMonth=NO;
    }
    else{
        cell.lbl.text=[NSString stringWithFormat:@"%ld",(long)item.day];
        cell.lbl.textColor=[UIColor blackColor];
        cell.isDayInCurMonth=YES;
    }
    [cell setNeedsLayout];
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *selectedItemIndexPaths = [collectionView indexPathsForSelectedItems];
    for(NSIndexPath* p in selectedItemIndexPaths) {
        [collectionView deselectItemAtIndexPath:p animated:NO];
    }
    return YES;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray* tempArr=_dataDic[@"dataArr"];
    WHUCalendarItem* item=tempArr[indexPath.row];
    _selectedDateString=item.dateStr;
    if(_onDateSelectBlk!=nil){
        _onDateSelectBlk(self.selectedDate);
    }
}

-(NSDate*)selectedDate{
  if(_selectedDateString==nil)
      return nil;
    return [_calcal dateFromString:_selectedDateString];
}



- (CGSize)sizeThatFits:(CGSize)size {
    if(size.width<300){
        size.width=300;
    }
    CGFloat height=((size.width-WHUCalendarView_Margin_Horizon)/7.0f)*6;
    height+=(WHUCalendarView_TopView_Height+WHUCalendarView_WeekView_Height);
    size.height=height;
    return size;
}

@end
