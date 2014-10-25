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


@property(nonatomic,strong)NSMutableArray *dataArray;//里面装字典 key为天数  数据源



@end
