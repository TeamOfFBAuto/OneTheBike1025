//
//  RootViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/26.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    BOOL state = [[NSUserDefaults standardUserDefaults]boolForKey:LOGIN_STATE];
//    
//    if (state == YES) {
//        return;
//    }
//    
//    [self loginView];
//}

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    BOOL state = [[NSUserDefaults standardUserDefaults]boolForKey:LOGIN_STATE];
//    
//    if (state == YES) {
//        return;
//    }
//    
//    [self loginView];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginView) name:NOTIFICATION_CHANGE_USER object:nil];
}

- (void)loginView
{
    LoginViewController *login = [[LoginViewController alloc]init];
    [self presentViewController:login animated:NO completion:^{
        
    }];
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

@end
