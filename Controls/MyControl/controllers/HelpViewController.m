//
//  HelpViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/12/15.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()<UIWebViewDelegate>
{
    MBProgressHUD *loading;
}

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"帮助说明";
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64)];
    [self.view addSubview:webView];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.c1t1.cn"]]];
    
    loading = [LTools MBProgressWithText:@"数据加载" addToView:self.view];
    [loading show:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading hide:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [loading hide:YES];
}


@end
