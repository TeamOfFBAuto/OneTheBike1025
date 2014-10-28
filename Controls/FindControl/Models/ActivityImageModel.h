//
//  ActivityImageModel.h
//  OneTheBike
//
//  Created by soulnear on 14-10-27.
//  Copyright (c) 2014年 szk. All rights reserved.
//
/*
 **活动详情页图片model
 */

#import <Foundation/Foundation.h>

@interface ActivityImageModel : NSObject



@property(nonatomic,strong)NSString * atmtId;
@property(nonatomic,strong)NSString * atmtPath;
@property(nonatomic,strong)NSString * infoRef;
@property(nonatomic,strong)NSString * playFlg;
@property(nonatomic,strong)NSString * playNum;
@property(nonatomic,strong)NSString * sortNum;
@property(nonatomic,strong)NSString * thumbnailUrl;
@property(nonatomic,strong)NSString * type;



-(id)initWithDic:(NSDictionary *)dic;
@end
