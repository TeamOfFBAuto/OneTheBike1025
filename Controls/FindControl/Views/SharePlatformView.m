//
//  SharePlatformView.m
//  OneTheBike
//
//  Created by soulnear on 14-10-25.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "SharePlatformView.h"

@implementation SharePlatformView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)buttonTap1:(id)sender
{
    share_block(0);
}
- (IBAction)buttonTap3:(id)sender {
    share_block(2);
}

- (IBAction)buttonTap2:(id)sender {
    share_block(1);
}

- (IBAction)buttonTap4:(id)sender {
    share_block(3);
}

- (IBAction)buttonTap5:(id)sender {
    share_block(4);
}

- (IBAction)buttonTap6:(id)sender {
    share_block(5);
}


-(void)setShareBlock:(SharePlatformViewBlock)aBlock
{
    share_block = aBlock;
}



@end
