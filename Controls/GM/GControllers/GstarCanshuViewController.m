
//
//  GstarCanshuViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GstarCanshuViewController.h"
#import "GStartViewController.h"
#import "GyundongCustomView.h"

@interface GstarCanshuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tabelView;
}
@end

@implementation GstarCanshuViewController

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    if ([[[UIDevice currentDevice]systemVersion]doubleValue] >=7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    
    //自定义导航栏
    UIView *shangGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 35)];
    shangGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(5, 0, 35, 35)];
    [btn addTarget:self action:@selector(gGoBackVc) forControlEvents:UIControlEventTouchUpInside];
    [shangGrayView addSubview:btn];
    [self.view addSubview:shangGrayView];
    
    _imageArray = @[[UIImage imageNamed:@"gtime.png"],[UIImage imageNamed:@"gpodu.png"],[UIImage imageNamed:@"gpeisu.png"],[UIImage imageNamed:@"gpashenglv"],[UIImage imageNamed:@"ghaibashang.png"],[UIImage imageNamed:@"ghaibaxia.png"],[UIImage imageNamed:@"gpingjunsudu.png"],[UIImage imageNamed:@"gzuigaosudu.png"]];
    _titleArray = @[@"时间",@"坡度",@"配速",@"爬升率",@"海拔上升",@"海拔下降",@"平均速度",@"最高速度"];
    
    _tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 55, 320, iPhone5?(568-55):(480-55)) style:UITableViewStylePlain];
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    [self.view addSubview:_tabelView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gGoBackVc{
    [self.navigationController popViewControllerAnimated:YES];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //图标
    UIImageView *titleImv = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 25, 25)];
    [titleImv setImage:_imageArray[indexPath.row]];
    [cell.contentView addSubview:titleImv];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleImv.frame)+5, titleImv.frame.origin.y, 60, 25)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = RGBCOLOR(190, 190, 190);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = _titleArray[indexPath.row];
    [cell.contentView addSubview:titleLabel];
    
    //内容
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+90, titleImv.frame.origin.y, 100, 25)];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = RGBCOLOR(190, 190, 190);
    contentLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:contentLabel];
    
    
//    //调试颜色
//    titleLabel.backgroundColor = [UIColor grayColor];
//    contentLabel.backgroundColor = [UIColor orangeColor];
    
    
    
    switch (indexPath.row) {
        case 0://时间
        {
            contentLabel.text = self.yundongModel.timeRunLabel.text;
        }
            break;
        case 1://坡度
        {
            contentLabel.text = self.yundongModel.podu;
        }
            break;
        case 2://配速
        {
            contentLabel.text = self.yundongModel.peisu;
        }
            break;
        case 3://爬升率
        {
            contentLabel.text = self.yundongModel.pashenglv;
        }
            break;
        case 4://海拔上升
        {
            int num = [self.yundongModel.maxHaiba intValue] - [self.yundongModel.startHaiba intValue];
            contentLabel.text = [NSString stringWithFormat:@"%d",num];
        }
            break;
        case 5://海拔下降
        {
            int num = [self.yundongModel.startHaiba intValue]-[self.yundongModel.minHaiba intValue];
            contentLabel.text = [NSString stringWithFormat:@"%d",num];
        }
            break;
        case 6://平均速度
        {
           
            contentLabel.text = self.yundongModel.dangqiansudu;
        }
            break;
        case 7://最高速度
        {
            contentLabel.text = self.yundongModel.maxSudu;
        }
            break;
        default:
            break;
    }
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *contentStr = @"";
    
    switch (indexPath.row) {
        case 0://时间
        {
            contentStr = self.yundongModel.timeRunLabel.text;
            BOOL isChange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"计时"]) {
                    isChange = NO;
                }
            }
            
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:nil withTag:self.passTag withType:@"计时"];
            }
            
            
        }
            break;
        case 1://坡度
        {
            
            contentStr = self.yundongModel.podu;
            BOOL isChange = YES;
            
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"坡度"]) {
                    isChange = NO;
                }
            }
            
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:@"%" withTag:self.passTag withType:@"坡度"];
            }
            
            
            
            
        }
            break;
        case 2://配速
        {
            
            contentStr =self.yundongModel.peisu;
            BOOL ischange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"配速"]) {
                    ischange = NO;
                }
            }
            
            if (ischange) {
                
                if (self.passTag == 51) {//顶部较宽 单位用分钟/公里
                    [self.delegate setImage:_imageArray[indexPath.row] andContent:nil andDanwei:@"分钟/公里" withTag:self.passTag withType:@"配速"];
                }else{//单位用m/km
                    [self.delegate setImage:_imageArray[indexPath.row] andContent:nil andDanwei:@"m/km" withTag:self.passTag withType:@"配速"];
                }
                
                
            }
            
            
        }
            break;
        case 3://爬升率
        {
            
            contentStr = self.yundongModel.pashenglv;
            BOOL isChange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"爬升率"]) {
                    isChange = NO;
                }
            }
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:nil andDanwei:@"米/分钟" withTag:self.passTag withType:@"爬升率"];
            }
            
            
        }
            break;
        case 4://海拔上升
        {
            
            contentStr = [NSString stringWithFormat:@"%d",([self.yundongModel.maxHaiba intValue] - [self.yundongModel.haiba intValue])];
            BOOL isChange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"海拔上升"]) {
                    isChange = NO;
                }
            }
            
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:@"米" withTag:self.passTag withType:@"海拔上升"];
            }
            
            
        }
            break;
        case 5://海拔下降
        {
            
            contentStr = [NSString stringWithFormat:@"%d",([self.yundongModel.startHaiba intValue]-[self.yundongModel.minHaiba intValue])];
            
            BOOL isChange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"海拔下降"]) {
                    isChange = NO;
                }
            }
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:@"米" withTag:self.passTag withType:@"海拔下降"];
            }
            
            
        }
            break;
        case 6://平均速度
        {
            contentStr = self.yundongModel.dangqiansudu;
            if (self.passTag == 51) {//顶部较宽 单位用 公里/时间
                
                BOOL isChange = YES;
                for (GyundongCustomView *view in self.delegate.fourCustomView) {
                    if ([view.viewTypeStr isEqualToString:@"速度"]) {
                        isChange = NO;
                    }
                }
                
                if (isChange) {
                    [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:@"公里/时" withTag:self.passTag withType:@"速度"];
                }
                
                
            }else{
                
                BOOL isChange = YES;
                for (GyundongCustomView *view in self.delegate.fourCustomView) {
                    if ([view.viewTypeStr isEqualToString:@"速度"]) {
                        isChange = NO;
                    }
                }
                
                if (isChange) {
                    [self.delegate setImage:_imageArray[indexPath.row] andContent:contentStr andDanwei:@"km/时" withTag:self.passTag withType:@"速度"];
                }
                
                
                
                
            }
            
            
            
        }
            break;
        case 7://最高速度
        {
            
            contentStr = self.yundongModel.maxSudu;
            
            BOOL isChange = YES;
            for (GyundongCustomView *view in self.delegate.fourCustomView) {
                if ([view.viewTypeStr isEqualToString:@"最高速度"]) {
                    isChange = NO;
                }
            }
            
            
            if (isChange) {
                [self.delegate setImage:_imageArray[indexPath.row] andContent:nil andDanwei:nil withTag:self.passTag withType:@"最高速度"];
            }
            
        }
            break;
        default:
            break;
    }
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - 隐藏或显示tabbar
- (void)hideTabBar:(BOOL) hidden{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? 568 : 480 , view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? (568-49):(480-49), view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320-49)];
            }
        }
    }
    
    [UIView commitAnimations];
}

@end
