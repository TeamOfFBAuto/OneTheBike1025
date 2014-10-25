//
//  StartViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "StartViewController.h"
#import "GStartViewController.h"
#import "GMapStarViewController.h"

@interface StartViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;
@end

@implementation StartViewController


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









@end
