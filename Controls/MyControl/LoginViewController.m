//
//  LoginViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/26.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LoginViewController.h"
#import "UMSocial.h"
#import "UserInfoClass.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    UIImageView *back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    back.image = [UIImage imageNamed:@"login"];
    [self.view addSubview:back];
    
    //title
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 115, screenSize.width, 72)];
    titleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleView];
    
    UILabel *title1 = [LTools createLabelFrame:CGRectMake(0, 0, titleView.width, 20) title:@"轮行天下 一路有你" font:16 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [titleView addSubview:title1];
    
    UILabel *title2 = [LTools createLabelFrame:CGRectMake(0, 52, titleView.width, 20) title:@"一 起 定 义 你 的 骑 行" font:16 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [titleView addSubview:title2];
    
    
    
    //登录view
    
    UIView *loginView = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 140 - (iPhone5 ? 20 : 5), screenSize.width, 95)];
    loginView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:loginView];
    
    UIButton *sina = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, 0, loginView.width, 45) normalTitle:@"新浪登入" image:[UIImage imageNamed:@"login_sina"] backgroudImage:nil superView:self.view target:self action:@selector(clickToSina:)];
    sina.imageEdgeInsets = UIEdgeInsetsMake(0, - 50, 0, 0);
    
    [loginView addSubview:sina];
    
    UIButton *QQ = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(0, sina.bottom, loginView.width, 45) normalTitle:@"QQ登入" image:[UIImage imageNamed:@"login_qq"] backgroudImage:nil superView:self.view target:self action:@selector(clickToQQ:)];
    QQ.imageEdgeInsets = UIEdgeInsetsMake(0, - 50 - 15, 0, 0);
    
    [loginView addSubview:QQ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createLoginView
{
    
}

- (IBAction)clickToSina:(id)sender {
    
    [self loginToPlat:UMShareToSina];
}

- (IBAction)clickToQQ:(id)sender {
    
    [self loginToPlat:UMShareToQQ];
}

- (void)loginToPlat:(NSString *)snsPlatName
{
    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
    
    __weak typeof(self)weakSelf = self;
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsPlatName];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        NSLog(@"login response is %@",response);
        
        //获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatName];
            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
            
            [weakSelf loginToServer:snsAccount.usid nickName:snsAccount.userName icon:snsAccount.iconURL platName:snsPlatName];
            
        }
        
    });
}

#pragma mark - 事件处理

- (void)autoShareToSina
{
    UIImage *shareImage = [UIImage imageNamed:@"share_Image"];
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:@"@骑叭官微 安装完成，据说这是专门为自行车运动极客打造的骑行软件，先用为快了哦，哈哈" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

- (void)autoShareToQQ
{
    UIImage *shareImage = [UIImage imageNamed:@"share_Image"];
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:@"分享内嵌文字" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}


//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    
}

#pragma mark - 数据解析

#pragma mark - 网络请求

- (void)loginToServer:(NSString *)otherUserId nickName:(NSString *)nickName icon:(NSString *)icon platName:(NSString *)platName{
    NSString *url = [NSString stringWithFormat:BIKE_LOGIN,otherUserId,nickName,icon];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int status = [[result objectForKey:@"status"]integerValue];
        if (status == 1) {
//            NSDictionary *dic = [result objectForKey:@"custJson"];
             UserInfoClass* loginUser = [[UserInfoClass alloc]initWithDictionary:result];
            
            [LTools cache:loginUser.custId ForKey:USER_CUSTID];
            [LTools cache:loginUser.headPhoto ForKey:USER_HEAD_IMAGEURL];
            [LTools cache:loginUser.nickName ForKey:USER_NAME];
            [LTools cache:loginUser.gold ForKey:USER_GOLD];
            
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:LOGIN_STATE];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            if ([platName isEqualToString:UMShareToQQ]) {
                
//                [self autoShareToQQ];
            }else
            {
                [self autoShareToSina];
            }
            
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
    }];
}



@end
