//
//  GhistoryViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/30.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GhistoryViewController : UIViewController
{
    UITableView *_tableView;
}

@property(nonatomic,strong)NSMutableArray *netDataArray;//请求到的网络数据数组

@property(nonatomic,strong)UILabel *topTotalDistanceLabel;//最上面总距离label
@property(nonatomic,strong)UILabel *totalCishuLabel;//运动次数label
@property(nonatomic,strong)UILabel *totalYongshiLabel;//总用时label

@end
