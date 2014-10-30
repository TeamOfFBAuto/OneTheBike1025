//
//  HistoryViewController.h
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRoadClass.h"

@interface HistoryViewController : UIViewController
{
    NSMutableArray * _fangkaiArray;
}


@property(nonatomic,strong)NSMutableArray *netDataArray;//请求到的网络数据数组

@property(nonatomic,strong)NSMutableArray *dataArray;//二维数组


@property(nonatomic,strong)NSMutableArray *localDataArray;//本地数据



@property(nonatomic,strong)UILabel *topTotalDistanceLabel;//最上面总距离label
@property(nonatomic,strong)UILabel *totalCishuLabel;//运动次数label
@property(nonatomic,strong)UILabel *totalYongshiLabel;//总用时label



@end
