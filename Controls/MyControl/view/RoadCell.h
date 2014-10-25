//
//  RoadCell.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoadCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

@end
