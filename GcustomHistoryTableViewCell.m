//
//  GcustomHistoryTableViewCell.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GcustomHistoryTableViewCell.h"
#import "LRoadClass.h"
#import "GyundongCanshuModel.h"

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



-(void)loadCustomCellWithMoedle:(GyundongCanshuModel*)theModel{
    //图标
    UIImageView *titleImv  = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    [titleImv setImage:[UIImage imageNamed:@"ghistoryBike.png"]];
    [self.contentView addSubview:titleImv];
    
    //时间label
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleImv.frame)+10, 5, 200, 20)];
    self.timeLabel.textColor = RGBCOLOR(105, 105, 105);
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.timeLabel];
    
    
    //信息label
    self.sportInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeLabel.frame.origin.x, CGRectGetMaxY(self.timeLabel.frame)+5, 200, 20)];
    self.sportInfoLabel.font = [UIFont systemFontOfSize:14];
    self.sportInfoLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.sportInfoLabel];
    
    //距离
    self.spotrdistanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.sportInfoLabel.frame)+10, titleImv.frame.origin.y, 60, 30)];
//    self.spotrdistanceLabel.backgroundColor = [UIColor redColor];
    self.spotrdistanceLabel.text = [NSString stringWithFormat:@"%.1fkm",theModel.juli];
    [self.contentView addSubview:self.spotrdistanceLabel];
    
    //星期
    
    NSLog(@"%@",theModel.startTime);
    NSString *tt = [theModel.startTime substringToIndex:theModel.startTime.length-3];
    int xx = [GMAPI getWeekDayFromDateStr:tt];
    NSString *xingqiStr = [GMAPI getWeekStrWithInt:xx];
    //年月
    NSString *yearMonth = [NSString stringWithFormat:@"%@.%@",[theModel.startTime substringWithRange:NSMakeRange(5, 2)],[theModel.startTime substringWithRange:NSMakeRange(8, 2)]];
    //时分秒
    NSString *hhmmssStr1 = [theModel.startTime substringWithRange:NSMakeRange(11, 5)];
    NSString *hhmmssStr2 = [theModel.endTime substringWithRange:NSMakeRange(11, 5)];
    NSString *hhmmssStr = [NSString stringWithFormat:@"%@-%@",hhmmssStr1,hhmmssStr2];
    
    //具体时间
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@ %@",yearMonth,xingqiStr,hhmmssStr];
    
    
    
    
    
    
    
    
    
    
    self.sportInfoLabel.text = [NSString stringWithFormat:@"均速: %.1fkm 用时: %@",theModel.pingjunsudu,theModel.yongshi];
    
    
    
    
    
    
    //调试颜色
//    titleImv.backgroundColor = [UIColor grayColor];
//    self.timeLabel.backgroundColor = [UIColor redColor];
//    self.sportInfoLabel.backgroundColor = [UIColor blueColor];
//    self.spotrdistanceLabel.backgroundColor = [UIColor orangeColor];
    
}



@end
