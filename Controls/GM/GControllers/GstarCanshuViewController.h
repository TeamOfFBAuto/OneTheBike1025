//
//  GstarCanshuViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//


//运动参数界面
#import <UIKit/UIKit.h>
@class GStartViewController;

#import "GyundongCanshuModel.h"

@interface GstarCanshuViewController : UIViewController
{
    NSArray *_imageArray;
    NSArray *_titleArray;
}

@property(nonatomic,assign)NSInteger passTag;
@property(nonatomic,assign)GStartViewController *delegate;
@property(nonatomic,strong)GyundongCanshuModel *yundongModel;


@end
