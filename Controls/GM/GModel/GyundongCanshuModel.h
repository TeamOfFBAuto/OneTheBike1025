//
//  GyundongCanshuModel.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

//运动参数model

#import <Foundation/Foundation.h>

@interface GyundongCanshuModel : NSObject



@property(nonatomic,assign)NSString* podu;//坡度
@property(nonatomic,assign)NSString* pashenglv;//爬升率
@property(nonatomic,assign)NSString* bpm;//卡路里


@property(nonatomic,strong)NSString * juli;//距离 单位公里
@property(nonatomic,strong)NSString * dangqiansudu;//当前速度 定位返回对象的属性
@property(nonatomic,assign)NSString* pingjunsudu;//平均速度
@property(nonatomic,assign)NSString* maxSudu;//最高速度
@property(nonatomic,assign)NSString* peisu;//配速//跑完一公里需要的时间


@property(nonatomic,strong)NSString *startTime;//开始时间
@property(nonatomic,strong)NSString *endTime;//结束时间
@property(nonatomic,strong)NSString *yongshi;//用时

@property(nonatomic,strong)NSString *startHaiba;//开始海拔
@property(nonatomic,strong)NSString *maxHaiba;//最高海拔
@property(nonatomic,strong)NSString *minHaiba;//最低海拔
@property(nonatomic,strong)NSString *haiba;//实时海拔 完成骑行之后这个参数为重点海拔


@property(nonatomic,strong)NSString *startCoorStr;//开始时候的经纬度  用逗号隔开
@property(nonatomic,strong)NSString *coorStr;//实时经纬度 定位结束后为终点经纬度


@property(nonatomic,assign)MAUserLocation *userLocation;//用户定位信息



//计时器label
@property(nonatomic,strong)UILabel *timeRunLabel;

//本地时间label
@property(nonatomic,strong)UILabel *localTimeLabel;


//清空所有数据
-(void)cleanAllData;


-(id)init;

@end
