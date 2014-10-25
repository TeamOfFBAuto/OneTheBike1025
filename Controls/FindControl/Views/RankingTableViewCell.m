//
//  RankingTableViewCell.m
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RankingTableViewCell.h"

@implementation RankingTableViewCell

- (void)awakeFromNib
{
    self.header_imageView.layer.cornerRadius = 5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
