//
//  GGTimeLineView.m
//  Taurus
//
//  Created by 王刚 on 2018/12/11.
//  Copyright © 2018年 LOVER. All rights reserved.
//

/**
 参考文章
 https://blog.csdn.net/nethanhan/article/details/72466559
 https://www.jianshu.com/p/7e8d3b845331
 https://github.com/danielgindi/Charts
 */

#import "GGTimeLineView.h"

#define GGW self.frame.size.width
#define GGH self.frame.size.height
#define KlineHeight APP_Origin_Y(172)
#define totolTime 242
@interface GGTimeLineView()

/**分时线路径*/
@property (nonatomic, strong) UIBezierPath * timeLinePath;
/**分时线*/
@property (nonatomic, strong) CAShapeLayer * timelineLayer;
/**填充背景*/
@property (nonatomic, strong) CAShapeLayer * fillColorLayer;
/**均值路径*/
@property (nonatomic, strong) UIBezierPath * averageLinePath;
/**均值线*/
@property (nonatomic, strong) CAShapeLayer * averageLayer;
/**纵坐标最大值*/
@property (nonatomic, assign) double max;
/**纵坐标中间值*/
@property (nonatomic, assign) double mid;
/**纵坐标最小值*/
@property (nonatomic, assign) double min;




/**最新点坐标*/
@property (nonatomic, assign) CGPoint currentPoint;
/**是否显示背景*/
@property (nonatomic, assign) BOOL isNeedBackgroundColor;
/**心跳点*/
@property (nonatomic, strong) CALayer * heartLayer;

/**十字光标*/
@property (nonatomic, strong) CAShapeLayer * crossLayer;
/**十字光标时间轴文字*/
@property (nonatomic, strong) CATextLayer * crossTimeLayer;
/**十字光标价格轴文字*/
@property (nonatomic, strong) CATextLayer * crossPriceLayer;

@end

@implementation GGTimeLineView

-(void)removeAllLayer{
    self.layer.sublayers = nil;
    [self.layer removeFromSuperlayer];
}

//alloc方法调用
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupGestureRecognize];
        //初始化数据
        [self initData];
    }
    return self;
}

#pragma mark --画图方法
-(void)drawBgFramework{
    UIBezierPath * path = [[UIBezierPath alloc] init];
    NSString * temString = @"";
    //五条横线
    CGFloat rowSpace = KlineHeight/4;

    for (int i = 0; i<5; i++) {
        [path moveToPoint:CGPointMake(APP_Origin_X(0), rowSpace*i)];
        [path addLineToPoint:CGPointMake(GGW, rowSpace*i)];
    }
    //五条竖线
    CGFloat colSpace = (GGW)/4.0;
    for (int i = 0; i<5; i++) {
        [path moveToPoint:CGPointMake(colSpace*i, 0)];
        [path addLineToPoint:CGPointMake(colSpace*i, KlineHeight)];
        //画文字
        //偏移量
        float offset = 0.0;
        //文字排版
        CATextLayerAlignmentMode mode;
        if (i == 0) {
            temString = @"9:30";
            offset = APP_Origin_X(3);
            mode = kCAAlignmentLeft;
        }else if (i == 1) {
            temString = @"";
        }else if (i == 2) {
            temString = @"11:30";
            offset = -APP_Origin_X(35)/2;
            mode = kCAAlignmentCenter;
        }else if (i == 3) {
            temString = @"";
        }else if (i == 4) {
            temString = @"15:00";
            offset = -APP_Origin_X(35);
            mode = kCAAlignmentRight;
        }
        [self drawLabelAtRect:CGRectMake(colSpace*i+offset, KlineHeight ,APP_Origin_X(35),APP_Origin_Y(20)) textString:temString textAligment:mode];
    }
    CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.strokeColor = [UIColor colorWithHexString:@"AAAAAA"].CGColor;
    //设置虚线效果
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithFloat:0.5], nil]];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.path = path.CGPath;
    [self.layer addSublayer:shapeLayer];
    //分割线
    UIImageView * separateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.upperViewHeight, GGW, 1)];
    separateLine.backgroundColor = [UIColor colorWithHexString:separateLineColor];
    [self addSubview:separateLine];
}


/**画文字,直接创建一个CATextLayer*/
-(void)drawLabelAtRect:(CGRect)rect textString:(NSString *)textString textAligment:(CATextLayerAlignmentMode)textLayerAlignment{
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    [self.layer addSublayer:textLayer];
    
    textLayer.foregroundColor = [UIColor colorWithHexString:@"AAAAAA"].CGColor;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.alignmentMode = textLayerAlignment;
    textLayer.wrapped = YES;
    
    UIFont * font = [APPFont getSysFont8];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    textLayer.string = textString;
}

#pragma mark --数据入口
-(void)setDataArray:(NSMutableArray<GGTimeLineItem *> *)dataArray{
    _dataArray = dataArray;
    [self drawTimeLine];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    //确定峰值
    int vv = 0.0;
    for (int i = 0; i<self.dataArray.count; i++) {
        GGTimeLineItem * item = self.dataArray[i];
        if (vv<[item.Volume intValue]) {
            vv = [item.Volume intValue];
        }
    }
    //成交量柱状图
    for (int i = 0; i<self.dataArray.count; i++) {
        GGTimeLineItem * item = self.dataArray[i];
        UIColor * color = [UIColor colorWithHexString:baseRedColor];
        if (i%2 == 0) {
            color = [UIColor colorWithHexString:baseGreenColor];
        }
        float volume = [item.Volume floatValue];
        [self drawTradingVolume:gc color:color rect:CGRectMake(GGW/totolTime*i, self.upperViewHeight+self.downViewHeight*(1-volume/vv), GGW/totolTime, self.downViewHeight*(volume/vv))];
    }
}

-(void)drawTimeLine{
    GGTimeLineItem * item = self.dataArray[0];

    self.max = [item.MaxPrice doubleValue];
    self.min = [item.MinPrice doubleValue];
    self.mid = [item.CurrentPrice doubleValue];
    //最高价至最低价区间
    double priceManage = self.max - self.min;
    //横向标注
    [self drawLabelAtRect:CGRectMake(0, 0, APP_Origin_X(30), APP_Origin_Y(10)) textString:item.MaxPrice textAligment:kCAAlignmentLeft];
    [self drawLabelAtRect:CGRectMake(0, KlineHeight*1/2-APP_Origin_Y(10), APP_Origin_X(30), APP_Origin_Y(10)) textString:item.CurrentPrice textAligment:kCAAlignmentLeft];
    [self drawLabelAtRect:CGRectMake(0, KlineHeight-APP_Origin_Y(10), APP_Origin_X(30), APP_Origin_Y(10)) textString:item.MinPrice textAligment:kCAAlignmentLeft];
    //均值线初始
    double initAveOffset = self.max-[item.AvgPirce doubleValue];
    CGPoint initPoint = CGPointMake(0, KlineHeight*(initAveOffset/priceManage));
    [self.averageLinePath addLineToPoint:initPoint];
    [self.averageLinePath moveToPoint:initPoint];

    for (int i = 0; i<self.dataArray.count; i++) {
        /**分时线*/
        GGTimeLineItem * item = self.dataArray[i];
        //偏移时间
        NSString * offsetTime = [ToolClass oneDate:item.CurrentTime minusAnother:@"09:30" withFormat:@"mm:ss"];
//        DbugLog(@"%@",offsetTime);
        //价格差
        double priceOffset = self.max-[item.CurrentPrice doubleValue];
        int offset = [offsetTime intValue];
        CGPoint point = CGPointMake(GGW*offset/totolTime, KlineHeight*(priceOffset/priceManage));
        [self.timeLinePath addLineToPoint:point];
        self.timelineLayer.path = self.timeLinePath.CGPath;
        /**均线*/
        double averageOffset = self.max-[item.AvgPirce doubleValue];
        CGPoint avePoint = CGPointMake(GGW*offset/totolTime, KlineHeight*(averageOffset/priceManage));
        [self.averageLinePath addLineToPoint:avePoint];
        self.averageLayer.path = self.averageLinePath.CGPath;
    }
}

-(void)drawTradingVolume:(CGContextRef)gc color:(UIColor *)color rect:(CGRect)frame{
    //填充颜色和填充框
    CGContextSetFillColorWithColor(gc, color.CGColor);
    CGContextFillRect(gc, frame);
}

-(void)addNewItem:(GGTimeLineItem *)item{
    //偏移时间
    NSString * offsetTime = [ToolClass oneDate:item.CurrentTime minusAnother:@"09:30" withFormat:@"mm:ss"];
    //最高价至最低价区间
    double priceManage = self.max - self.min;
    //价格差
    double priceOffset = self.max-[item.CurrentPrice doubleValue];
    int offset = [offsetTime intValue];
    CGPoint point = CGPointMake(GGW*offset/totolTime, KlineHeight*(priceOffset/priceManage));
    [self.timeLinePath addLineToPoint:point];
    self.timelineLayer.path = self.timeLinePath.CGPath;
    /**均线*/
    double averageOffset = self.max-[item.AvgPirce doubleValue];
    CGPoint avePoint = CGPointMake(GGW*offset/totolTime, KlineHeight*(averageOffset/priceManage));
    [self.averageLinePath addLineToPoint:avePoint];
    self.averageLayer.path = self.averageLinePath.CGPath;
    
    [self.dataArray addObject:item];
    [self setNeedsDisplay];
}
/**置零所有线*/
-(void)initData{
    CGPoint point = CGPointMake(APP_Origin_X(0), KlineHeight*2/5);
    [self.timeLinePath addLineToPoint:point];
    [self.timeLinePath moveToPoint:point];
    //继续向路径中添加下面两个点 形成闭合区间
    self.timelineLayer.path = self.timeLinePath.CGPath;
    [self.layer addSublayer:self.timelineLayer];
    //添加均线
    self.averageLayer.path = self.averageLinePath.CGPath;
    [self.layer addSublayer:self.averageLayer];
}

#pragma mark --懒加载
-(UIBezierPath *)timeLinePath{
    if (!_timeLinePath) {
        _timeLinePath = [[UIBezierPath alloc] init];
    }
    return _timeLinePath;
}

-(CAShapeLayer *)timelineLayer{
    if (!_timelineLayer) {
        _timelineLayer = [[CAShapeLayer alloc] init];
        _timelineLayer.strokeColor = [UIColor colorWithHexString:selectColor].CGColor;
        _timelineLayer.fillColor = [UIColor clearColor].CGColor;
        _timelineLayer.lineWidth = 1.0f;
    }
    return _timelineLayer;
}

-(UIBezierPath *)averageLinePath{
    if (!_averageLinePath) {
        _averageLinePath = [[UIBezierPath alloc] init];
    }
    return _averageLinePath;
}

-(CAShapeLayer *)averageLayer{
    if (!_averageLayer) {
        _averageLayer = [[CAShapeLayer alloc] init];
        _averageLayer.strokeColor = [UIColor clearColor].CGColor;
        _averageLayer.fillColor = [UIColor clearColor].CGColor;
        _averageLayer.lineWidth = 2.0f;
    }
    return _averageLayer;
}

-(CAShapeLayer *)fillColorLayer{
    if (!_fillColorLayer) {
        _fillColorLayer = [[CAShapeLayer alloc] init];
        _fillColorLayer.fillColor = [UIColor blueColor].CGColor;
        _fillColorLayer.strokeColor = [UIColor clearColor].CGColor;
        //设置图层的位置，防止覆盖
        _fillColorLayer.zPosition -= 1;
    }
    return _fillColorLayer;
}










-(CALayer *)heartLayer{
    if (!_heartLayer) {
        _heartLayer = [[CALayer alloc] init];
        _heartLayer.backgroundColor = [UIColor blueColor].CGColor;
    }
    return _heartLayer;
}

-(CAShapeLayer *)crossLayer{
    if (!_crossLayer) {
        _crossLayer = [[CAShapeLayer alloc] init];
        _crossLayer.lineDashPattern = @[@1,@2];
    }
    return _crossLayer;
}

-(CATextLayer *)crossPriceLayer{
    if (!_crossPriceLayer) {
        _crossPriceLayer = [[CATextLayer alloc] init];
    }
    return _crossPriceLayer;
}

-(CATextLayer *)crossTimeLayer{
    if (!_crossTimeLayer) {
        _crossTimeLayer = [[CATextLayer alloc] init];
    }
    return _crossTimeLayer;
}

#pragma mark --GestureRecognize
/**添加手势*/
-(void)setupGestureRecognize{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

/**长按*/
-(void)longPressAction:(UILongPressGestureRecognizer *)gesture{
    CGPoint temPoint = [gesture locationInView:self];
    //越界处理
    if (temPoint.x >= GGW) {
        temPoint = CGPointMake(GGW, temPoint.y);
    }
    if (temPoint.x < 0) {
        temPoint = CGPointMake(0, temPoint.y);
    }
    if (temPoint.y >= GGH-60) {
        temPoint = CGPointMake(temPoint.x, GGH-60);
    }
    if (temPoint.y < 0) {
        temPoint = CGPointMake(temPoint.x, 0);
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
//        [self drawCrossLineWithPoint:temPoint];
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
//        [self drawCrossLineWithPoint:temPoint];
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

/**点击*/
-(void)tapAction:(UITapGestureRecognizer *)gesture{
    self.crossLayer.path = nil;
    [self.crossPriceLayer removeFromSuperlayer];
    [self.crossTimeLayer removeFromSuperlayer];
}







/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
