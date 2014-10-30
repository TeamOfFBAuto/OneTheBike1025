//
//  GcustomHistoryTableViewCell.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LRoadClass;
@class GyundongCanshuModel;

@interface GcustomHistoryTableViewCell : UITableViewCell


@property(nonatomic,strong)UILabel *timeLabel;//时间label
@property(nonatomic,strong)UILabel *sportInfoLabel;//运动信息label
@property(nonatomic,strong)UILabel *spotrdistanceLabel;//距离



-(void)loadCustomCellWithMoedle:(GyundongCanshuModel*)theModel;


@end
