//
//  GGTimeLineItem.m
//  Taurus
//
//  Created by 王刚 on 2018/12/11.
//  Copyright © 2018年 LOVER. All rights reserved.
//

#import "GGTimeLineItem.h"

@implementation GGTimeLineItem


-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super initWithDict:dict];
    if (self) {
        self.amount = [NSString stringWithFormat:@"%@",dict[@"amount"]];
        self.AvgPirce = [NSString stringWithFormat:@"%@",dict[@"avgPrice"]];
        self.change = [NSString stringWithFormat:@"%@",dict[@"change"]];
        self.ClosePrice = [NSString stringWithFormat:@"%@",dict[@"close"]];
        
        NSString * current = [NSString stringWithFormat:@"%@",dict[@"current"]];
        float currentF = [current floatValue];
        NSString * current0 = [NSString stringWithFormat:@"%.2f",currentF];
        self.CurrentPrice = current0;
        
        NSString * time = [NSString stringWithFormat:@"%@",dict[@"date"]];
        NSArray * timeArr = [time componentsSeparatedByString:@" "];
        NSString * time0 = timeArr[1];
        NSArray * time0Arr = [time0 componentsSeparatedByString:@":"];
        NSString * time1 = [[NSString alloc] init];
        time1 = [NSString stringWithFormat:@"%@:%@",time0Arr[0],time0Arr[1]];
        BOOL result = [time1 compare:@"11:30"] == NSOrderedDescending;
        if (result) {
            //下午开盘
            int hh = [time0Arr[0] intValue];
            int mm = [time0Arr[1] intValue];
            int tt = hh*60+mm;
            
            int t = 89;
            
            int result = tt-t;
            int second = (int)result%60;
            int minute = (int)result/60;
            time1 = [NSString stringWithFormat:@"%d:%d",minute,second];
//            DbugLog(@"%@",time1);
        }
        self.CurrentTime = time1;
        
        self.MaxPrice = [NSString stringWithFormat:@"%@",dict[@"high"]];
        self.MinPrice = [NSString stringWithFormat:@"%@",dict[@"low"]];
        self.percent = [NSString stringWithFormat:@"%@",dict[@"percent"]];
        self.stockSymbol = [NSString stringWithFormat:@"%@",dict[@"stockSymbol"]];
        self.DataTime_stamp = [NSString stringWithFormat:@"%@",dict[@"timestamp"]];
        self.LastVolume_trade = [NSString stringWithFormat:@"%@",dict[@"volume"]];
        self.Volume = [NSString stringWithFormat:@"%@",dict[@"volume"]];
    }
    return self;
}

@end
