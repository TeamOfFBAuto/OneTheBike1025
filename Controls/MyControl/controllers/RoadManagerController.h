//
//  RoadManagerController.h
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//


//路书
#import <UIKit/UIKit.h>
typedef enum{
    Action_Normal = 0,//正常
    Action_SelectRoad //路书选择
}Action_Type;

typedef void(^SelectRoadBlock)(NSString *serverRoadId,NSString *roadlineJson);

@interface RoadManagerController : UITableViewController
{
    SelectRoadBlock _selectBlock;
}

@property(nonatomic,assign)Action_Type actionType;

- (void)selectRoadlineBlock:(SelectRoadBlock)aRoadBlock;

@end
