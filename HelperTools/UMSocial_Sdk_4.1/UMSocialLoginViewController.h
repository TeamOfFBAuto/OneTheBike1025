//
//  UMSocialLoginViewController.h
//  SocialSDK
//
//  Created by yeahugo on 13-5-19.
//  Copyright (c) 2013年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "FBBaseViewController.h"
@interface UMSocialLoginViewController : FBBaseViewController
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIActionSheetDelegate,
    UMSocialUIDelegate
>
{
    IBOutlet UITableView *_snsTableView;
    IBOutlet UISwitch *_changeSwitcher;
}
@end
