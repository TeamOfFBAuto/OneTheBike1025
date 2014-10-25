//
//  RankingModel.h
//  OneTheBike
//
//  Created by soulnear on 14-10-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankingModel : NSObject

///用户id
@property(nonatomic,strong)NSString * custId;
///用户头像
@property(nonatomic,strong)NSString * headPhoto;
///用户名
@property(nonatomic,strong)NSString * nickName;
///名次
@property(nonatomic,strong)NSString * rowid;
///总公里数
@property(nonatomic,strong)NSString * sumCyclingKm;

-(id)initWithDic:(NSDictionary *)dic;

@end
