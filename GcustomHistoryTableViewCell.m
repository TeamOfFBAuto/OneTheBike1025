//
//  GcustomHistoryTableViewCell.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GcustomHistoryTableViewCell.h"
#import "LRoadClass.h"

@implementation GcustomHistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    
    return self;
}



-(void)loadCustomCellWithMoedle:(LRoadClass*)theModel{
    //图标
    UIImageView *titleImv  = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    [self.contentView addSubview:titleImv];
    
    //时间label
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleImv.frame)+10, 5, 200, 20)];
    [self.contentView addSubview:self.timeLabel];
    
    //信息label
    self.sportInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeLabel.frame.origin.x, CGRectGetMaxY(self.timeLabel.frame)+5, 200, 20)];
    [self.contentView addSubview:self.sportInfoLabel];
    
    //距离
    self.spotrdistanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.sportInfoLabel.frame)+20, titleImv.frame.origin.y, 30, 30)];
    [self.contentView addSubview:self.spotrdistanceLabel];
    
    
    self.timeLabel.text = theModel.dateline;
    self.spotrdistanceLabel.text = theModel.distance;
    
    
    
    
    //调试颜色
//    titleImv.backgroundColor = [UIColor grayColor];
//    self.timeLabel.backgroundColor = [UIColor redColor];
//    self.sportInfoLabel.backgroundColor = [UIColor blueColor];
//    self.spotrdistanceLabel.backgroundColor = [UIColor orangeColor];
    
}



@end
