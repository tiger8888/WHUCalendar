//
//  WHUCalendarCal.m
//  TEST_Calendar
//
//  Created by SuperNova(QQ:422596694) on 15/11/5.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "WHUCalendarCal.h"
#import "WHUCalendarItem.h"
#import "WHUCalendarMarcro.h"
#import <UIKit/UIKit.h>
#define WHUCALENDAR_SECOND_PER_DAY (24 * 60 * 60)
@interface WHUCalendarCal()
{
    NSCalendar* _lunarCalendar;
    NSArray* _lunarDays;
    NSArray* _lunarMonths;
}
@property(nonatomic,strong) NSCalendar* curCalendar;
@property(nonatomic,strong) NSString* curDateStr;
@property(nonatomic,strong) NSDictionary* preCalMap;
@property(nonatomic,strong) NSDictionary* nextCalMap;
@property(nonatomic,strong) NSDictionary* currentCalMap;
@end


@implementation WHUCalendarCal

-(id)init{
    self=[super init];
    if(self){
        _workQueue=dispatch_queue_create("WHUCalendarCal_Work_Queue", DISPATCH_QUEUE_SERIAL);
        _lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        _lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        //农历日期名
        _lunarDays =[NSArray arrayWithObjects:@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                     @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                     @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
        
        //农历月份名
        _lunarMonths=  [NSArray arrayWithObjects:@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    }
    return self;
}

-(NSCalendar*)curCalendar{
    if(_curCalendar==nil){
        _curCalendar=[NSCalendar currentCalendar];
    }
    return _curCalendar;
}

-(NSString*)currentDateStr{
    if(_curDateStr==nil){
        NSDate* curDate=[NSDate date];
        NSDateComponents* firstDayOfMonth=[self componentOfDate:curDate];
        self.curDateStr =[NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)firstDayOfMonth.year,(long)firstDayOfMonth.month,(long)firstDayOfMonth.day];
    }
    return _curDateStr;
}

-(NSDictionary*)loadDataWith:(NSString*)dateStr{
    self.currentCalMap=[self calendarMapWith:[self dateFromMonthString:dateStr]];
    WHUCalendarView_WeakSelf weakself=self;
    dispatch_async(_workQueue, ^{
        WHUCalendarView_StrongSelf self=weakself;
        if(self.preCalMap==nil){
            self.preCalMap=[self getPreCalendarMap:dateStr];
        }
        if(self.nextCalMap==nil){
            self.nextCalMap=[self getNextCalendarMap:dateStr];
        }
    });
    return _currentCalMap;
}

-(void)getCalendarMapWith:(NSString*)dateStr completion:(void(^)(NSDictionary* dic))completeBlk{
    WHUCalendarView_WeakSelf weakself=self;
    dispatch_async(_workQueue, ^{
        WHUCalendarView_StrongSelf self=weakself;
        NSString* nextMonthStr=[self nextMonthOfMonthString:dateStr];
        NSString* preMonthStr=[self preMonthOfMonthString:dateStr];
        if(self.preCalMap!=nil&&[self.preCalMap[@"monthStr"] isEqualToString:dateStr]){
            NSDictionary* tempCur=self.currentCalMap;
            self.currentCalMap=self.preCalMap;
            [self dealDateOnMainQueue:completeBlk];
            if(tempCur!=nil&&[tempCur[@"monthStr"] isEqualToString:nextMonthStr]){
                self.nextCalMap=tempCur;
            }
            else{
                self.nextCalMap=nil;
            }
            self.preCalMap=nil;
        }
        else if(self.nextCalMap!=nil&&[self.nextCalMap[@"monthStr"] isEqualToString:dateStr]){
            NSDictionary* tempCur=self.currentCalMap;
            self.currentCalMap=self.nextCalMap;
            [self dealDateOnMainQueue:completeBlk];
            if(tempCur!=nil&&[tempCur[@"monthStr"] isEqualToString:preMonthStr]){
                self.preCalMap=tempCur;
            }
            else{
                self.preCalMap=nil;
            }
            self.nextCalMap=nil;
        }
        else{
            if([_currentCalMap[@"monthStr"] isEqualToString:dateStr]){
                [self dealDateOnMainQueue:completeBlk];
            }
            else{
                self.currentCalMap=[self calendarMapWith:[self dateFromMonthString:dateStr]];
                [self dealDateOnMainQueue:completeBlk];
            }
            self.nextCalMap=nil;
            self.preCalMap=nil;
        }
        
        if(self.preCalMap==nil){
            self.preCalMap=[self getPreCalendarMap:dateStr];
        }
        
        if(self.nextCalMap==nil){
            self.nextCalMap=[self getNextCalendarMap:dateStr];
        }
        
    });
    
    
}


-(void)dealDateOnMainQueue:(void(^)(NSDictionary*))completeBlk{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completeBlk!=nil){
            completeBlk(_currentCalMap);
        }
    });
}


-(NSDictionary*)calendarMapWith:(NSDate*)date{
    NSMutableDictionary* mdic=[NSMutableDictionary dictionary];
    NSMutableArray* dateArr=[NSMutableArray array];
    NSCalendar *cal = self.curCalendar;
    NSDate* curDate=date;
    NSRange days = [cal rangeOfUnit:NSDayCalendarUnit
                             inUnit:NSMonthCalendarUnit
                            forDate:curDate];
    NSDateComponents* firstDayOfMonth=[self componentOfDate:curDate];
    firstDayOfMonth.day=1;
    NSDate* fdate=[cal dateFromComponents:firstDayOfMonth];
    firstDayOfMonth=[self componentOfDate:fdate];
    //从周日开始为1,2,3,4,5,6,7
    if(firstDayOfMonth.weekday!=1){
        NSInteger weekGap=firstDayOfMonth.weekday-1;
        if(weekGap<0) weekGap+=7;
        NSDate* firstDate=[fdate dateByAddingTimeInterval:-WHUCALENDAR_SECOND_PER_DAY*weekGap];
        NSDateComponents* firstComponent=[self componentOfDate:firstDate];
        for(int i=0;i<weekGap;i++){
            WHUCalendarItem* item=[[WHUCalendarItem alloc] init];
            item.dateStr=[NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)firstComponent.year,(long)firstComponent.month,(long)firstComponent.day];
            item.day=-(firstComponent.day);
            [self LunarForSolarYear:item andComponent:firstComponent];
            firstComponent.day++;
            [dateArr addObject:item];
        }
    }
    NSDateComponents* curComponents=[self componentOfDate:curDate];
    [mdic setObject:[NSString stringWithFormat:@"%ld年%ld月",(long)curComponents.year,(long)curComponents.month] forKey:@"monthStr"];
    for(int i=1;i<=days.length;i++){
        WHUCalendarItem* item=[[WHUCalendarItem alloc] init];
        curComponents.day=i;
        item.dateStr=[NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)(curComponents.year),(long)curComponents.month,(long)i];
        item.day=i;
        [self LunarForSolarYear:item andComponent:curComponents];
        [dateArr addObject:item];
    }
    
    NSDateComponents* lastDayOfMonth=[self componentOfDate:curDate];
    lastDayOfMonth.day=days.length;
    NSDate* ldate=[cal dateFromComponents:lastDayOfMonth];
    lastDayOfMonth=[self componentOfDate:ldate];
    if(lastDayOfMonth.weekday!=0||dateArr.count<42){
        NSInteger weekGap=8-lastDayOfMonth.weekday;
        NSDate* lastDate=[ldate dateByAddingTimeInterval:WHUCALENDAR_SECOND_PER_DAY*weekGap];
        NSDateComponents* lastComponent=[self componentOfDate:lastDate];
        for(int i=1;i<=weekGap;i++){
            WHUCalendarItem* item=[[WHUCalendarItem alloc] init];
            item.dateStr=[NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)lastComponent.year,(long)lastComponent.month,(long)i];
            item.day=-i;
            lastComponent.day=i;
            [self LunarForSolarYear:item andComponent:lastComponent];
            [dateArr addObject:item];
        }
        if(dateArr.count<42){
                NSInteger leftCount=42-dateArr.count;
                for(NSInteger i=weekGap+1;i<=weekGap+leftCount;i++){
                    WHUCalendarItem* item=[[WHUCalendarItem alloc] init];
                    item.dateStr=[NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)lastComponent.year,(long)lastComponent.month,(long)i];
                    item.day=-i;
                    lastComponent.day=i;
                    [self LunarForSolarYear:item andComponent:lastComponent];
                    [dateArr addObject:item];
                    if(dateArr.count>42){
                        break;
                    }
                }
        }
    }
    
    
    [mdic setObject:[dateArr copy] forKey:@"dataArr"];
    return [mdic copy];
}


-(NSDictionary*)getCalendarMapWith:(NSString*)dateStr{
    NSDate* date=[self dateFromMonthString:dateStr];
    return [self calendarMapWith:date];
}


-(NSDate*)dateFromString:(NSString*)dateString{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate* date=[format dateFromString:dateString];
    return date;
}

-(NSString*)stringFromTimeStamp:(NSInteger)timeStamp{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeStr = [formatter stringFromDate:confromTimesp];
    return timeStr;
}

-(void)preMonthCalendar:(NSString*)dateStr complete:(void(^)(NSDictionary*))completionBlk{
    NSString* preMonthStr=[self preMonthOfMonthString:dateStr];
    [self getCalendarMapWith:preMonthStr completion:completionBlk];
}

-(void)nextMonthCalendar:(NSString*)dateStr complete:(void(^)(NSDictionary*))completionBlk{
    NSString* preMonthStr=[self nextMonthOfMonthString:dateStr];
    [self getCalendarMapWith:preMonthStr completion:completionBlk];
}

-(NSDictionary*)getPreCalendarMap:(NSString*)dateStr{
    NSDate* date=[self dateFromMonthString:dateStr];
    NSDateComponents* com=[self componentOfDate:date];
    com.month-=1;
    if(com.month<=0){
        com.month+=12;
        com.year-=1;
    }
    date=[self.curCalendar dateFromComponents:com];
    return [self calendarMapWith:date];
}

-(NSDictionary*)getNextCalendarMap:(NSString*)dateStr{
    NSDate* date=[self dateFromMonthString:dateStr];
    NSDateComponents* com=[self componentOfDate:date];
    com.month+=1;
    if(com.month>12){
        com.month-=12;
        com.year+=1;
    }
    date=[self.curCalendar dateFromComponents:com];
    return [self calendarMapWith:date];
}

-(NSString*)preMonthOfMonthString:(NSString*)dateStr{
    NSDate* date=[self dateFromMonthString:dateStr];
    NSDateComponents* com=[self componentOfDate:date];
    com.month-=1;
    if(com.month<=0){
        com.month+=12;
        com.year-=1;
    }
    return [NSString stringWithFormat:@"%ld年%ld月",(long)com.year,(long)com.month];
}


-(NSString*)nextMonthOfMonthString:(NSString*)dateStr{
    NSDate* date=[self dateFromMonthString:dateStr];
    NSDateComponents* com=[self componentOfDate:date];
    com.month+=1;
    if(com.month>12){
        com.month-=12;
        com.year+=1;
    }
    return [NSString stringWithFormat:@"%ld年%ld月",(long)com.year,(long)com.month];
}


-(NSDate*)dateFromMonthString:(NSString*)dateStr{
    dateStr=[dateStr stringByAppendingString:@"01"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy年MM月dd"];
    NSDate* date=[format dateFromString:dateStr];
    return date;
}


-(NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy年M月"];
    return [format stringFromDate:date];
}

-(NSDateComponents*)componentOfDate:(NSDate*)date{
    NSCalendar *cal = self.curCalendar;
    NSDateComponents* com=[cal components: NSCalendarUnitWeekday|NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    com.hour=0;
    com.minute=0;
    com.second=0;
    return com;
}

#pragma mark - 农历转换函数

-(void)LunarForSolarYear:(WHUCalendarItem *)calendarDay andComponent:(NSDateComponents*)com{
    
    
    NSString *solarYear = [self LunarForSolarYear:[_curCalendar dateFromComponents:com]];
    
    NSArray *solarYear_arr= [solarYear componentsSeparatedByString:@"-"];
    
    if([solarYear_arr[0]isEqualToString:@"正"] &&
       [solarYear_arr[1]isEqualToString:@"初一"]){
        
        //正月初一：春节
        calendarDay.holiday = @"春节";
        
    }else if([solarYear_arr[0]isEqualToString:@"正"] &&
             [solarYear_arr[1]isEqualToString:@"十五"]){
        
        
        //正月十五：元宵节
        calendarDay.holiday = @"元宵";
        
    }else if([solarYear_arr[0]isEqualToString:@"二"] &&
             [solarYear_arr[1]isEqualToString:@"初二"]){
        
        //二月初二：春龙节(龙抬头)
        calendarDay.holiday = @"龙抬头";
        
    }else if([solarYear_arr[0]isEqualToString:@"五"] &&
             [solarYear_arr[1]isEqualToString:@"初五"]){
        
        //五月初五：端午节
        calendarDay.holiday = @"端午";
        
    }else if([solarYear_arr[0]isEqualToString:@"七"] &&
             [solarYear_arr[1]isEqualToString:@"初七"]){
        
        //七月初七：七夕情人节
        calendarDay.holiday = @"七夕";
        
    }else if([solarYear_arr[0]isEqualToString:@"八"] &&
             [solarYear_arr[1]isEqualToString:@"十五"]){
        
        //八月十五：中秋节
        calendarDay.holiday = @"中秋";
        
    }else if([solarYear_arr[0]isEqualToString:@"九"] &&
             [solarYear_arr[1]isEqualToString:@"初九"]){
        
        //九月初九：重阳节、中国老年节（义务助老活动日）
        calendarDay.holiday = @"重阳";
        
    }else if([solarYear_arr[0]isEqualToString:@"腊"] &&
             [solarYear_arr[1]isEqualToString:@"初八"]){
        
        //腊月初八：腊八节
        calendarDay.holiday = @"腊八";
        
    }else if([solarYear_arr[0]isEqualToString:@"腊"] &&
             [solarYear_arr[1]isEqualToString:@"二十四"]){
        
        
        //腊月二十四 小年
        calendarDay.holiday = @"小年";
        
    }else if([solarYear_arr[0]isEqualToString:@"腊"] &&
             [solarYear_arr[1]isEqualToString:@"三十"]){
        
        //腊月三十（小月二十九）：除夕
        calendarDay.holiday = @"除夕";
        
    }
    
    
    calendarDay.Chinese_calendar = solarYear_arr[1];
    
    NSString* commonHoliday=[self CommonHoliday:com];
    if(commonHoliday!=nil){
        calendarDay.holiday=commonHoliday;
    }
}


-(NSString*)CommonHoliday:(NSDateComponents*)calendarDay{
    if (calendarDay.month == 1 &&
        calendarDay.day == 1){
        return @"元旦";
        
        //2.14情人节
    }else if (calendarDay.month == 2 &&
              calendarDay.day == 14){
        return @"情人节";
        
        //3.8妇女节
    }else if (calendarDay.month == 3 &&
              calendarDay.day == 8){
        return @"妇女节";
        
        //5.1劳动节
    }else if (calendarDay.month == 5 &&
              calendarDay.day == 1){
        return @"劳动节";
        
        //6.1儿童节
    }else if (calendarDay.month == 6 &&
              calendarDay.day == 1){
        return @"儿童节";
        
        //8.1建军节
    }else if (calendarDay.month == 8 &&
              calendarDay.day == 1){
        return @"建军节";
        
        //9.10教师节
    }else if (calendarDay.month == 9 &&
              calendarDay.day == 10){
        return @"教师节";
        
        //10.1国庆节
    }else if (calendarDay.month == 10 &&
              calendarDay.day == 1){
        return @"国庆节";
        
        //11.1植树节
    }else if (calendarDay.month == 3 &&
              calendarDay.day == 12){
        return @"植树节";
        
        //11.11光棍节
    }else if (calendarDay.month == 11 &&
              calendarDay.day == 11){
        return @"光棍节";
    }
    return nil;
}

-(NSString *)LunarForSolarYear:(NSDate*)date{
    NSInteger day = [_lunarCalendar components:NSCalendarUnitDay fromDate:date].day;
    NSString* dayStr=_lunarDays[day-1];
    NSInteger month = [_lunarCalendar components:NSCalendarUnitMonth fromDate:date].month;
    NSString* monthStr=_lunarMonths[month-1];
    NSString *lunarDate = [NSString stringWithFormat:@"%@-%@",monthStr,dayStr];
    
    return lunarDate;
}
@end
