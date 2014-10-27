//
//  PublicDefine.h
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#ifndef OneTheBike_PublicDefine_h
#define OneTheBike_PublicDefine_h

#import "PublicDefine.h"
#import "LTools.h"
#import "LMapTools.h"
#import "UIColor+ConvertColor.h"
#import "UIView+Frame.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "JSONKit.h"
#import "UMFeedback.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]


#define USER_NAME @"user_name"
#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_HEAD_IMAGEURL @"head_image_url"//
#define USER_GOLD @"gold" //轨币

#define USER_QIANMIN @"qianming"//签名
#define USER_HIGHT @"height" //身高
#define USER_WEIGHT @"weight"//体重

#define USER_CUSTID @"custid"//服务器返回用户id

#define LOGIN_STATE @"successOrFail"//登录状态 yes or no

#define ROAD_IDS @"road_ids"//路书id

#define APP_ID @"605673005"

#define BACK_IMAGE [UIImage imageNamed:@"backButton"]
#define NAVIGATION_IMAGE [UIImage imageNamed:@"navigationBack"]

#define NOTIFICATION_CHANGE_USER @"CHANGE_USER"//更换账户

//=========================接口

#define BIKE_LOGIN @"http://182.254.242.58:8080/QiBa/QiBa/custAction_xxloginxx.action?loginId=%@&nickName=%@&headPhoto=%@"//登录

#define BIKE_ROAD_LINE @"http://182.254.242.58:8080/QiBa/QiBa/roadBookAction_saveRdbk.action?custId=%@&beginSite=%@&waySite=%@&endSite=%@&beginCoordinates=%@&wayCoordinates=%@&endCoordinates=%@&distance=%@"//保存路书

#define BIKE_ROAD_LIST @"http://182.254.242.58:8080/QiBa/QiBa/roadBookAction_queryRdbkListByPage.action?custId=%@&page=%d"//路书列表

#define BIKE_ROAD_DELETE @"http://182.254.242.58:8080/QiBa/QiBa/roadBookAction_deleteRdbk.action?rdbkId=%@"

#define BIKE_USER_INFO @"http://182.254.242.58:8080/QiBa/QiBa/custAction_loadCust.action?custId=%@"//个人信息

#define BIKE_EDIT_USERINFO @"http://182.254.242.58:8080/QiBa/QiBa/custAction_updateCust.action?custId=%@&nickName=%@&sex=%d&cellphone=%@&personSign=%@&height=%@&weight=%@&birthday=%@&city=%@"//修改个人信息

#endif
