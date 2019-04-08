//
//  GGTimeLineView.h
//  Taurus
//
//  Created by 王刚 on 2018/12/11.
//  Copyright © 2018年 LOVER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGTimeLineItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGTimeLineView : UIView

@property (nonatomic, strong)NSMutableArray<GGTimeLineItem *> * dataArray;

@property (nonatomic, assign) float upperViewHeight;            //上部分占高
@property (nonatomic, assign) float downViewHeight;             //下部分占高

/**
 *  @brief                  画背景图
 */
-(void)drawBgFramework;
/**
 *  @brief                  数据入口
 */
-(void)setDataArray:(NSMutableArray<GGTimeLineItem *> *)dataArray;
/**
 *  @brief                  单独添加数据入口
 */
-(void)addNewItem:(GGTimeLineItem *)item;

/**
 *  @brief                  移除所有图层
 */
-(void)removeAllLayer;

@end

NS_ASSUME_NONNULL_END
