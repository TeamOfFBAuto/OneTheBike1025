//
//  GhistoryViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GhistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableview;
    
    NSMutableArray *_dataArray;
}

@property(nonatomic,strong)UILabel *topTotalDistanceLabel;//最上面总距离label
@property(nonatomic,strong)UILabel *totalCishuLabel;//运动次数label
@property(nonatomic,strong)UILabel *totalYongshiLabel;//总用时label


@end
