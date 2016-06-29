//
//  WHUCalDrawView.m
//  Created by SuperNova on 16/4/3.
//  Copyright (c) 2015年 SuperNova(QQ:422596694). All rights reserved.
//

#import "WHUCalDrawView.h"
#import <CoreText/CoreText.h>
#import "WHUCalendarCal.h"
#import "WHUCalendarItem.h"
#define WHUCalView_LINE_WIDTH (1.0 / [UIScreen mainScreen].scale)
#define WHUCalView_LINE_WIDTH_LINE_ADJUST_OFFSET ((1.0 / [UIScreen mainScreen].scale) / 2)
@interface WHUCalDrawView()
{
    WHUCalendarItem* _selectedDateItem;
    NSInteger _colQty;
    NSInteger _rowQty;
    CGFloat _itemH;
    CGFloat _itemW;
    CGPoint _originPoint;
    CGRect _tapedRect;
    CGRect _hilightRect;
    NSDictionary* _tagDic;
}
@property(nonatomic,assign) CGFloat lineWidth;
@property(nonatomic,strong) NSArray* rectArray;
@end
@implementation WHUCalDrawView
+ (Class)layerClass
{
    return [CAShapeLayer class];
}


-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self!=nil){
        [self setupView];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        [self setupView];
    }
    return self;
}

-(void)setupView{
    _itemH=0;
    _itemW=0;
    _selectedDateItem=nil;
    _tapedRect=CGRectZero;
    _calcal=[[WHUCalendarCal alloc] init];
}


-(void)calItemMetricsRow:(NSInteger)row col:(NSInteger)col inset:(UIEdgeInsets)inset{
    CGRect bounds=self.bounds;
    CGFloat itemWidth=((bounds.size.width-inset.left-inset.right)/(CGFloat)col);
    CGFloat itemHeight=((bounds.size.height-inset.top-inset.bottom)/(CGFloat)row);
    if(itemHeight>itemWidth){
        itemHeight=itemWidth;
    }
    else{
        itemWidth=itemHeight;
    }
    CGPoint origin=CGPointMake(inset.left, inset.top);
    _itemH=itemHeight;
    _itemW=itemWidth;
    _originPoint=origin;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor=[UIColor whiteColor];
    self.lineWidth=WHUCalView_LINE_WIDTH;
//    self.dataDic=[_calcal loadDataWith:[_calcal stringFromDate:[NSDate date]]];
    NSArray* tempArr=_dataDic[@"dataArr"];
    _colQty=7;
    _rowQty=tempArr.count/_colQty;
    CAShapeLayer* shapeLayer=(CAShapeLayer*)self.layer;
    shapeLayer.contentsScale = [[UIScreen mainScreen] scale];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.lineWidth = 1.0/[UIScreen mainScreen].scale;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = [self gridPathRow:_rowQty col:_colQty inset:UIEdgeInsetsMake(0, 0, 0, 0)].CGPath;
    shapeLayer.strokeStart=0;
    shapeLayer.strokeEnd=1.0f;
}

-(void)reloadData{
    [self setNeedsDisplay];
}


-(CGFloat)heightOfString:(NSMutableAttributedString*)str width:(CGFloat)width{
CGRect paragraphRect = [str boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    return paragraphRect.size.height;
}


-(UIBezierPath*)textDrawPath:(CGRect)bounds{
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    bounds=CGRectApplyAffineTransform(bounds, trans);
    CGFloat tx=bounds.origin.x;
    CGFloat ty=bounds.origin.y;
    CGAffineTransform trans1=CGAffineTransformMakeTranslation(-tx, -ty);
    bounds=CGRectApplyAffineTransform(bounds, trans1);
    CGFloat midx=CGRectGetMidX(bounds)-10;
    CGFloat maxx=CGRectGetMaxX(bounds);
    CGFloat maxy=CGRectGetMaxY(bounds);
    UIBezierPath* path=[UIBezierPath bezierPath];
    {
        CGFloat midy=CGRectGetMidY(bounds)+5;
        CGFloat my= midy/2.0;
        [path moveToPoint:CGPointMake(0, my-10)];
        [path addLineToPoint:CGPointMake(midx+10, my-10)];
        [path addLineToPoint:CGPointMake(maxx, midy)];
        [path addLineToPoint:CGPointMake(maxx,maxy)];
        [path addLineToPoint:CGPointMake(0, maxx)];
    }
    [path closePath];
    CGAffineTransform trans2=CGAffineTransformMakeTranslation(tx, ty);
    [path applyTransform:trans2];
    [path applyTransform:trans];
    return path;
}


-(UIBezierPath*)extraLabelDrawPath:(CGRect)bounds delta:(CGFloat)delta{
    //    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    //    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    //    UIBezierPath* p=[self extraLabelFillPath:bounds];
    //    CGAffineTransform trans1=CGAffineTransformMakeScale(1, 1);
    //    [p applyTransform:trans1];
    //    [p applyTransform:trans];
    //    return p;
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    bounds=CGRectApplyAffineTransform(bounds, trans);
    CGFloat tx=bounds.origin.x;
    CGFloat ty=bounds.origin.y;
    CGAffineTransform trans1=CGAffineTransformMakeTranslation(-tx, -ty);
    bounds=CGRectApplyAffineTransform(bounds, trans1);
    CGFloat midx=CGRectGetMidX(bounds)-10;
    CGFloat midy=CGRectGetMidY(bounds)+10;
    CGFloat maxx=CGRectGetMaxX(bounds);
    CGFloat midx1=CGRectGetMidX(bounds)-5;
    CGFloat mx=  midx1+midx1/2.0f-4+10;
    UIBezierPath* path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(midx-delta, 0)];
    [path addLineToPoint:CGPointMake(mx+delta, 0)];
    CGFloat midy1=CGRectGetMidY(bounds)+5;
    CGFloat my= midy1/2.0;
    [path addLineToPoint:CGPointMake(maxx, my-delta)];
    [path addLineToPoint:CGPointMake(maxx, midy)];
    [path closePath];
    CGAffineTransform trans2=CGAffineTransformMakeTranslation(tx, ty);
    [path applyTransform:trans2];
    [path applyTransform:trans];
    return path;
}

-(UIBezierPath*)extraFillPath:(CGRect)bounds{
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    UIBezierPath* p=[self extraLabelFillPath:bounds];
    [p applyTransform:trans];
    return p;
}

-(UIBezierPath*)extraLabelFillPath:(CGRect)bounds{
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    bounds=CGRectApplyAffineTransform(bounds, trans);
    CGFloat tx=bounds.origin.x;
    CGFloat ty=bounds.origin.y;
    CGAffineTransform trans1=CGAffineTransformMakeTranslation(-tx, -ty);
    bounds=CGRectApplyAffineTransform(bounds, trans1);
    CGFloat midx=CGRectGetMidX(bounds)-10;
    CGFloat midy=CGRectGetMidY(bounds)+10;
    CGFloat maxx=CGRectGetMaxX(bounds);
    UIBezierPath* path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(midx, 0)];
    {
        CGFloat midx=CGRectGetMidX(bounds)-5;
        CGFloat mx=  midx+midx/2.0f-4+10;
        [path addLineToPoint:CGPointMake(mx, 0)];
        CGFloat midy=CGRectGetMidY(bounds)+5;
        CGFloat my= midy/2.0;
        [path addLineToPoint:CGPointMake(maxx, my)];
    }
    [path addLineToPoint:CGPointMake(maxx, midy)];
    [path closePath];
    CGAffineTransform trans2=CGAffineTransformMakeTranslation(tx, ty);
    [path applyTransform:trans2];
    return path;
}

-(void)setCurrentMonthDate:(NSDate *)currentMonthDate{
    if(![_currentMonthDate isEqualToDate:currentMonthDate]){
        _tagDic=nil;
                    [self setNeedsDisplay];
            dispatch_async(_calcal.workQueue,^{
                NSDateComponents* comp=[_calcal componentOfDate:currentMonthDate];
                NSArray* _calm=@[@(comp.year),@(comp.month)];
                NSArray* tempArr=_dataDic[@"dataArr"];
                NSMutableDictionary* mdic=[[NSMutableDictionary alloc] init];
                for(NSInteger i=0;i<tempArr.count;i++){
                    WHUCalendarItem* item=tempArr[i];
                    NSArray* arr=[item.dateStr componentsSeparatedByString:@"-"];
                    if(_tagStringOfDate!=nil){
                        NSString* tagString=_tagStringOfDate(_calm,arr);
                        mdic[item.dateStr]=tagString;
                    }
                }
                self->_tagDic=[mdic copy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsDisplay];
                });
            });
            
    }
    _currentMonthDate=currentMonthDate;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    int i=0;
    NSArray* tempArr=_dataDic[@"dataArr"];
    NSInteger selectIndex=[tempArr indexOfObject:_selectedDateItem];
    if(selectIndex!=NSNotFound){
        CGRect r=[[_rectArray objectAtIndex:selectIndex] CGRectValue];
            [self fillContext:context color:[UIColor colorWithRed:0xde/255.0 green:0xde/255.0 blue:0xde/255.0 alpha:1] rect:r];
    }
    for(NSValue* v in _rectArray){
        WHUCalendarItem* item=tempArr[i];
        NSMutableAttributedString* dayStr;
        NSMutableAttributedString* holiStr;
        if(item.holiday!=nil){
            holiStr=[[NSMutableAttributedString alloc] initWithString:item.holiday];
        }
        else{
            holiStr=[[NSMutableAttributedString alloc] initWithString:item.Chinese_calendar];
        }
        
        if(item.day<0){
            dayStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)-item.day]];
            [dayStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, dayStr.length)];
                [holiStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, holiStr.length)];
        }
        else{
            dayStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)item.day]];
            if([item.dateStr isEqualToString:[_calcal currentDateStr]]){
                [dayStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, dayStr.length)];
                [holiStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, holiStr.length)];
            }
            else{
                [holiStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, holiStr.length)];
                [dayStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, dayStr.length)];
            }
        }
        
        [dayStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14]range:NSMakeRange(0, dayStr.length)];
        [holiStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:10]range:NSMakeRange(0, holiStr.length)];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:dayStr];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attrString appendAttributedString:holiStr];
        
        NSMutableParagraphStyle* s=[[NSMutableParagraphStyle alloc] init];
        s.lineSpacing=0;
        s.paragraphSpacing=0;
        s.maximumLineHeight=14;
        s.alignment=NSTextAlignmentCenter;
        [attrString addAttribute:NSParagraphStyleAttributeName value:s range:NSMakeRange(0, [attrString length])];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect r=[v CGRectValue];
        CGFloat h=r.size.height-[self heightOfString:attrString width:300];
        r=UIEdgeInsetsInsetRect(r,UIEdgeInsetsMake(0, 0, h/2.0f, 0));
        
        NSString* tagString=_tagDic[item.dateStr];
        if(tagString!=nil){
            CGContextBeginPath(context);
            CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
            CGContextAddPath(context, [self extraFillPath:[v CGRectValue]].CGPath);
            CGContextFillPath(context);
            CGPathAddPath(path, NULL, [self textDrawPath:r].CGPath);
            NSString* showString=tagString;
            showString=[showString substringWithRange:NSMakeRange(0, 2)];
            NSMutableAttributedString* tagStr=[[NSMutableAttributedString alloc] initWithString:showString];
            [tagStr addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor magentaColor] range:NSMakeRange(0, tagStr.length)];
            [tagStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:10]range:NSMakeRange(0, tagStr.length)];
            NSMutableParagraphStyle* s=[[NSMutableParagraphStyle alloc] init];
            s.alignment=NSTextAlignmentCenter;
            [tagStr addAttribute:NSParagraphStyleAttributeName value:s range:NSMakeRange(0, [tagStr length])];
            CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)tagStr);
            CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [tagStr length]), [self extraLabelDrawPath:[v CGRectValue] delta:5].CGPath, NULL);
            NSArray *lines = (NSArray *)CTFrameGetLines(frame);
            if(lines.count==1){
                CFRelease(frame);
                CTFrameRef frame1 = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [tagStr length]), [self extraLabelDrawPath:[v CGRectValue] delta:0].CGPath, NULL);
                CTFrameDraw(frame1, context);
                CFRelease(frame1);
                CFRelease(frameSetter);
            }
            else{
                CTFrameDraw(frame, context);
                CFRelease(frame);
                CFRelease(frameSetter);
            }
        }
        else{
            CGPathAddRect(path, NULL, r);
        }
            CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
            CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attrString length]), path, NULL);
            CTFrameDraw(frame, context);
            CFRelease(frame);
            CFRelease(path);
            CFRelease(frameSetter);
        i++;
        
    }
    CGContextRestoreGState(context);
}




-(void)fillContext:(CGContextRef)context color:(UIColor*)color rect:(CGRect)r{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, r);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
//    CFRelease(path);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    _tapedRect=[self findTargetRectWith:touchPoint];
    
    BOOL canSelect=YES;
    if(_selectedDateItem!=nil&&_canSelectDate!=nil){
        canSelect=_canSelectDate(self.selectedDate);
    }
    if(canSelect&&_selectedDateItem!=nil){
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            if(_onDateSelectBlk!=nil){
                _onDateSelectBlk(self.selectedDate);
            }
        });
    }
    [self setNeedsDisplay];
}

-(NSDate*)selectedDate{
  if(_selectedDateItem==nil)
      return nil;
    return [_calcal dateFromString:_selectedDateItem.dateStr];
}


-(CGRect)findTargetRectWith:(CGPoint)touchPoint{

    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    touchPoint=CGPointApplyAffineTransform(touchPoint, trans);
    NSInteger index=0;
    for(NSValue* v in _rectArray){
        if(CGRectContainsPoint([v CGRectValue],touchPoint)){
        NSArray* tempArr=_dataDic[@"dataArr"];
        _selectedDateItem=tempArr[index];
          return [v CGRectValue];
        }
        index++;
    }
    return  CGRectZero;
}



-(void)adjustPoint:(CGPoint*)p with:(CGFloat)lineWidth{
    CGFloat pixelAdjustOffset =0;
    if (((int)(lineWidth * [UIScreen mainScreen].scale) + 1) % 2 == 0) {
        pixelAdjustOffset = WHUCalView_LINE_WIDTH_LINE_ADJUST_OFFSET;
    }
    (*p).x-=pixelAdjustOffset;
    (*p).y-=pixelAdjustOffset;
}


-(NSArray*)makeRectArrayRow:(NSInteger)row col:(NSInteger)col inset:(UIEdgeInsets)inset{
    CGRect bounds=self.bounds;
    [self calItemMetricsRow:row col:col inset:inset];
    CGFloat itemWidth=_itemW;
    CGFloat itemHeight=_itemH;
    CGPoint origin=_originPoint;
    NSMutableArray* array=[[NSMutableArray alloc] init];
    CGRect slice,columnRemainder;
    CGRect  rowRemainder=CGRectMake(origin.x, origin.y, col*itemWidth,row*itemHeight);
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    for (NSInteger i = 0; i < row; i++) {
        CGRectDivide(rowRemainder, &slice, &rowRemainder, itemHeight, CGRectMinYEdge);
        columnRemainder = slice;
        for (NSInteger j = 0; j < col; j++) {
            CGRectDivide(columnRemainder, &slice, &columnRemainder, itemWidth, CGRectMinXEdge);
            slice=CGRectApplyAffineTransform(slice, trans);
            [array addObject:[NSValue valueWithCGRect:slice]];
        }
    }
    
    return [array copy];
}

-(UIBezierPath*)gridPathRow:(NSInteger)row col:(NSInteger)col inset:(UIEdgeInsets)inset{
    [self calItemMetricsRow:row col:col inset:inset];
    CGFloat itemWidth=_itemW;
    CGFloat itemHeight=_itemH;
    CGPoint origin=_originPoint;
    CGPoint start=origin;
    start.y+=_lineWidth;
    [self adjustPoint:&start with:_lineWidth];
    CGRect  rect=CGRectMake(start.x, start.y, col*itemWidth,row*itemHeight);
    UIBezierPath* path=[UIBezierPath bezierPathWithRect:rect];
    NSMutableArray* marr=[[NSMutableArray alloc] init];
    CGRect temp=CGRectMake(0, 0, itemWidth, itemHeight);
    CGAffineTransform trans=CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    trans=CGAffineTransformScale(trans, 1.0, -1.0f);
    for(int i=0;i<row;i++){
        CGPoint p=start;
        p.y=(start.y+round(itemHeight*i));
        for(int j=0;j<col;j++){
            p.x=(start.x+round(itemWidth*j));
            temp.origin=p;
            CGRect t=CGRectApplyAffineTransform(temp, trans);
            [marr addObject:[NSValue valueWithCGRect:t]];
        }
    }
    for(int i=1;i<row;i++){
        CGPoint p=start;
        p.y=(p.y+round(itemHeight*i));
        CGPoint p1=p;
        p1.x=(p1.x+round(itemWidth*col));
        UIBezierPath* line=[UIBezierPath bezierPath];
        [line moveToPoint:p];
        [line addLineToPoint:p1];
        [path appendPath:line];
    }
    for(int i=1;i<col;i++){
        CGPoint p=start;
        p.x=(p.x+round(itemWidth*i));
        CGPoint p1=p;
        p1.y=(p1.y+round(itemHeight*row));
        UIBezierPath* line=[UIBezierPath bezierPath];
        [line moveToPoint:p];
        [line addLineToPoint:p1];
        [path appendPath:line];
    }
    _rectArray=[marr copy];
    return  path;
}
@end
