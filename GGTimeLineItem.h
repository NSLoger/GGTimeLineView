//
//  GGTimeLineItem.h
//  Taurus
//
//  Created by 王刚 on 2018/12/11.
//  Copyright © 2018年 LOVER. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGTimeLineItem : BaseModel

//分时线
@property (nonatomic, strong) NSString * amount;                    //成交额
@property (nonatomic, strong) NSString * AvgPirce;                  //平均价
@property (nonatomic, strong) NSString * change;                    //波动
@property (nonatomic, strong) NSString * ClosePrice;                //收盘价
@property (nonatomic, strong) NSString * CurrentPrice;              //当前价
@property (nonatomic, strong) NSString * CurrentTime;               //时间
@property (nonatomic, strong) NSString * MaxPrice;                  //最高
@property (nonatomic, strong) NSString * MinPrice;                  //最低
@property (nonatomic, strong) NSString * percent;                   //波动比
@property (nonatomic, strong) NSString * stockSymbol;               //股票编码
@property (nonatomic, strong) NSString * DataTime_stamp;            //标准时间戳
@property (nonatomic, strong) NSString * LastVolume_trade;          //
@property (nonatomic, strong) NSString * Volume;                    //成交量


@end

NS_ASSUME_NONNULL_END
