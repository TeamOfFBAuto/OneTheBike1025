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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            
            [weakSelf loginToServer:snsAccount.usid nickName:snsAccount.userName icon:snsAccount.iconURL];
            
        }
        
    });
}

#pragma mark - 事件处理



//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    
}

#pragma mark - 数据解析

#pragma mark - 网络请求

- (void)loginToServer:(NSString *)otherUserId nickName:(NSString *)nickName icon:(NSString *)icon
{
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
            
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
    }];
}



@end
