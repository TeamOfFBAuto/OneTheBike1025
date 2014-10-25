//
//  GyundongCustomView.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GyundongCustomView : UIView


@property(nonatomic,strong)UIImageView *titleImv;//图片
@property(nonatomic,strong)UILabel *titleLable;//标题
@property(nonatomic,strong)UILabel *contentLable;//内容
@property(nonatomic,strong)UILabel *danweiLabel;//计量单位

@property(nonatomic,strong)NSString *viewTypeStr;//类型

//分割线
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UIView *line1;



-(id)initWithFrame:(CGRect)frame;
@end
