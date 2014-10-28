//
//  ActivityDetailViewController.m
//  OneTheBike
//
//  Created by soulnear on 14-10-27.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "ActivityImageModel.h"
#import "CycleScrollView.h"
#import "CycleScrollModel.h"


@interface ActivityDetailViewController ()
{
    AFHTTPRequestOperation * opreation_request;
}

@property(nonatomic,strong)UIScrollView * myScrollView;

@property(nonatomic,strong)NSMutableArray * data_array;
@property(nonatomic,strong)CycleScrollView * mainScorllView;


@end

@implementation ActivityDetailViewController

-(void)clickToBack:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data_array = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton.width = -5;
    
    UIButton *_button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,0,40,44)];
    [_button_back addTarget:self action:@selector(clickToBack:) forControlEvents:UIControlEventTouchUpInside];
    [_button_back setImage:BACK_IMAGE forState:UIControlStateNormal];
    _button_back.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:_button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton,back_item];
    
    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"活动详情";
    
    _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT-64)];
    [self.view addSubview:_myScrollView];
    
    [self getData];
}


-(void)getData
{
    NSString * fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/activityAction_loadImageDtal.action?atmtId=%@",_aId];
    
    opreation_request = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]]];
    __weak typeof(self)bself = self;
    
    [opreation_request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSDictionary * allDic = [operation.responseString objectFromJSONString];
            
            bself.aModel = [[ActivityModel alloc] initWithDic:[allDic objectForKey:@"activity"]];
            
            NSArray * array = [allDic objectForKey:@"atmtList"];
            if ([array isKindOfClass:[NSArray class]] && array.count > 0)
            {
                NSArray * temp_array = [array objectAtIndex:0];
                if ([temp_array isKindOfClass:[NSArray class]] && temp_array.count > 0)
                {
                    for (NSDictionary * dic in temp_array) {
                        CycleScrollModel * model = [[CycleScrollModel alloc] init];
                        model.c_image_url = [dic objectForKey:@"thumbnailUrl"];
                        [bself.data_array addObject:model];
                    }
                }
                
                
                [bself setup];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
    [opreation_request start];
}

#pragma mark - 创建视图
-(void)setup
{
    float height = 20;
    
    CGRect rectr = [self.aModel.title boundingRectWithSize:CGSizeMake(DEVICE_WIDTH-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    UILabel * title_label = [[UILabel alloc] initWithFrame:CGRectMake(10,height,DEVICE_WIDTH-10,rectr.size.height)];
    title_label.text = _aModel.title;
    title_label.numberOfLines = 0;
    title_label.font = [UIFont systemFontOfSize:16];
    title_label.textAlignment = NSTextAlignmentLeft;
    title_label.textColor = RGBCOLOR(3,3,3);
    [_myScrollView addSubview:title_label];
    height += rectr.size.height;
    
    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0,height+10,320,175) animationDuration:5.0f WithDataArray:self.data_array];
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
    };
    [_myScrollView addSubview:self.mainScorllView];
    height += 175;
    
    CGRect rectr1 = [self.aModel.content boundingRectWithSize:CGSizeMake(DEVICE_WIDTH-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    
    UILabel * content_label = [[UILabel alloc] initWithFrame:CGRectMake(10,height+10,DEVICE_WIDTH-10,rectr1.size.height)];
    content_label.text = _aModel.title;
    content_label.font = [UIFont systemFontOfSize:14];
    content_label.textAlignment = NSTextAlignmentLeft;
    content_label.numberOfLines = 0;
    content_label.textColor = RGBCOLOR(3,3,3);
    [_myScrollView addSubview:content_label];
    
    height+=rectr1.size.height+10;
    
    _myScrollView.contentSize = CGSizeMake(0,height);    
}



-(void)dealloc
{
    [opreation_request cancel];
    opreation_request = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
