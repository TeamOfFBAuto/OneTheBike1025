//
//  ShareView.m
//  OneTheBike
//
//  Created by soulnear on 14-10-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "ShareView.h"
#import "SharePlatformView.h"
@implementation ShareView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        [self addGestureRecognizer:tap];
        
        _content_view = [[UIView alloc] initWithFrame:CGRectMake(0,DEVICE_HEIGHT,DEVICE_WIDTH,220)];
        _content_view.backgroundColor = [UIColor clearColor];
        [self addSubview:_content_view];
        
        SharePlatformView * share_view = [[[NSBundle mainBundle] loadNibNamed:@"SharePlatformView" owner:self options:nil] objectAtIndex:0];
        share_view.layer.cornerRadius = 8;
        share_view.backgroundColor = [UIColor whiteColor];
        share_view.frame = CGRectMake(0,0,300,150);
        share_view.center = CGPointMake(DEVICE_WIDTH/2,share_view.center.y);
        [_content_view addSubview:share_view];
        
        __weak typeof(self)wself = self;
        [share_view setShareBlock:^(int index) {
           
            [wself shareWithTag:index];
        }];
        
        
        UIButton * cancel_button = [UIButton buttonWithType:UIButtonTypeCustom];
        cancel_button.frame = CGRectMake(0,160,300,50);
        cancel_button.center = CGPointMake(DEVICE_WIDTH/2,cancel_button.center.y);
        cancel_button.backgroundColor = [UIColor whiteColor];
        cancel_button.layer.cornerRadius = 8;
        [cancel_button setTitle:@"取消" forState:UIControlStateNormal];
        [cancel_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancel_button addTarget:self action:@selector(cancelTap:) forControlEvents:UIControlEventTouchUpInside];
        [_content_view addSubview:cancel_button];
    }
    
    return self;
}

-(void)layoutSubviews
{
   
}



#pragma mark - 弹出视图
-(void)showInView:(UIView *)view WithAnimation:(BOOL)animation
{
    CGRect content_frame = _content_view.frame;
    content_frame.origin.y = DEVICE_HEIGHT -  content_frame.size.height;
    
    if (animation)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
            _content_view.frame = content_frame;
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _content_view.frame = content_frame;
    }
    [view addSubview:self];    
}


-(void)cancelTap:(UIButton *)sender
{
    CGRect content_frame = _content_view.frame;
    content_frame.origin.y = (iPhone5?568:480);
    
    [UIView animateWithDuration:0.3 animations:^{
        _content_view.frame = content_frame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)doTap:(UITapGestureRecognizer *)sender
{
    [self cancelTap:nil];
}


#pragma mark - 分享
-(void)shareWithTag:(int)tag
{
    NSLog(@"tag ------  %d",tag);
    
    NSArray * array = [NSArray arrayWithObjects:@"UMShareToSina",@"UMShareToWechatTimeline",@"UMShareToQzone",@"UMShareToTencent",@"UMShareToWechatSession",@"UMShareToQQ",nil];
    
    [[UMSocialControllerService defaultControllerService] setShareText:@"分享内嵌文字" shareImage:[UIImage imageNamed:@"icon"] socialUIDelegate:self];        //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler((UIViewController *)self.delegate,[UMSocialControllerService defaultControllerService],YES);
}

@end



















