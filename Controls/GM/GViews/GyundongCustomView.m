//
//  GyundongCustomView.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GyundongCustomView.h"

@implementation GyundongCustomView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    self.viewTypeStr = @"";
    self.titleImv = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectZero];
    self.titleLable.textAlignment = NSTextAlignmentRight;
    
    self.contentLable = [[UILabel alloc]initWithFrame:CGRectZero];
    self.contentLable.textAlignment = NSTextAlignmentRight;
    self.contentLable.font = [UIFont systemFontOfSize:25];
    
    self.danweiLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.danweiLabel.textAlignment = NSTextAlignmentLeft;
    self.danweiLabel.font = [UIFont systemFontOfSize:14];
    self.danweiLabel.textColor = RGBCOLOR(190, 190, 190);
    
    //分割线
    self.line = [[UIView alloc]initWithFrame:CGRectZero];
    self.line1 = [[UIView alloc]initWithFrame:CGRectZero];
    self.line.backgroundColor = RGBCOLOR(222, 222, 222);
    self.line1.backgroundColor = RGBCOLOR(222, 222, 222);
    
    
    
    //测试颜色
//    self.titleLable.backgroundColor = [UIColor redColor];
//    self.contentLable.backgroundColor = [UIColor grayColor];
//    self.danweiLabel.backgroundColor = [UIColor orangeColor];
//    self.line.backgroundColor = [UIColor blueColor];
//    self.line1.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.titleLable];
    [self addSubview:self.titleImv];
    [self addSubview:self.contentLable];
    [self addSubview:self.danweiLabel];
    [self addSubview:self.line];
    [self addSubview:self.line1];
    
    return self;
    
    
    
}

@end
