//
//  ShareView.h
//  OneTheBike
//
//  Created by soulnear on 14-10-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"

@protocol ShareViewDelegate <NSObject>



@end

@interface ShareView : UIView<UMSocialUIDelegate>
{
    UIView * _content_view;
}


@property(nonatomic,assign)id<ShareViewDelegate>delegate;

-(id)initWithFrame:(CGRect)frame;

-(void)showInView:(UIView *)view WithAnimation:(BOOL)animation;

@end
