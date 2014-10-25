//
//  ActivityTableViewCell.h
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewCell : UITableViewCell
{
    
}


@property (strong, nonatomic) IBOutlet UIImageView *header_imageView;


@property (strong, nonatomic) IBOutlet UILabel *title_label;

@property (strong, nonatomic) IBOutlet UILabel *sub_title_label;

@property (strong, nonatomic) IBOutlet UILabel *date_label;

@property (strong, nonatomic) IBOutlet UIButton *access_button;









@end
