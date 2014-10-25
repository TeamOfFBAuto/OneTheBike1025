//
//  SharePlatformView.h
//  OneTheBike
//
//  Created by soulnear on 14-10-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SharePlatformViewBlock)(int index);


@interface SharePlatformView : UIView
{
    SharePlatformViewBlock share_block;
}


@property (strong, nonatomic) IBOutlet UIButton *sina_button;
@property (strong, nonatomic) IBOutlet UIButton *weixin_circle_button;

@property (strong, nonatomic) IBOutlet UIButton *qqkongjian_button;

@property (strong, nonatomic) IBOutlet UIButton *qqweibo_button;

@property (strong, nonatomic) IBOutlet UIButton *weixin_friend_button;

@property (strong, nonatomic) IBOutlet UIButton *qqhaoyou_button;



- (IBAction)buttonTap1:(id)sender;
- (IBAction)buttonTap3:(id)sender;
- (IBAction)buttonTap2:(id)sender;
- (IBAction)buttonTap4:(id)sender;
- (IBAction)buttonTap5:(id)sender;
- (IBAction)buttonTap6:(id)sender;


-(void)setShareBlock:(SharePlatformViewBlock)aBlock;









@end
