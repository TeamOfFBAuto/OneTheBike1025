//
//  GhistoryViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/30.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "LoadingIndicatorView.h"


#import "GcustomHistoryTableViewCell.h"

#import "GHistoryDetailViewController.h"
#import "GyundongCanshuModel.h"
#import "GTimeSwitch.h"
#import "ShareView.h"

@interface GhistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray * _fangkaiArray;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int _currentPage;
    int _numOnePage;//每页几条数据
    
    //上提加载更多
    LoadingIndicatorView *_upMoreView;//上提加载更多
    BOOL _isUpMoreSuccess;//上提加载成功
    BOOL _isupMore;//是否为上提加载更多
    
    
    //请求轨迹数据 count为0 _currentPage不加
    int _guijiCount;
    
    int isOpen[2000];
    
    
    
}

@property(nonatomic,strong)NSMutableArray *netDataArray;//请求到的网络数据数组


@property(nonatomic,strong)NSMutableArray *dataArray;//二维数组

@property(nonatomic,strong)UILabel *topTotalDistanceLabel;//最上面总距离label
@property(nonatomic,strong)UILabel *totalCishuLabel;//运动次数label
@property(nonatomic,strong)UILabel *totalYongshiLabel;//总用时label

@end
