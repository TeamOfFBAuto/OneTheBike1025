//
//  MineViewController.h
//  OneTheBike
//
//  Created by lichaowei on 14-9-28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *table;


@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
#pragma mark - 事件处理

#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建

#pragma mark - delegate


#pragma mark - UITableViewDelegate