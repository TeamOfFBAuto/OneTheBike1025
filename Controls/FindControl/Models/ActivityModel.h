//
//  ActivityModel.h
//  OneTheBike
//
//  Created by soulnear on 14-10-23.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject
{
    
}


@property(nonatomic,strong)NSString * activityId;
@property(nonatomic,strong)NSString * beginTime;
@property(nonatomic,strong)NSString * content;
@property(nonatomic,strong)NSString * endTime;
@property(nonatomic,strong)NSString * source;
@property(nonatomic,strong)NSString * subtitle;
@property(nonatomic,strong)NSString * thumbnailUrl;
@property(nonatomic,strong)NSString * title;


-(id)initWithDic:(NSDictionary *)dic;

@end
