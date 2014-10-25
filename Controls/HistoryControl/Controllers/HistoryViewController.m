//
//  HistoryViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
}
@end

@implementation HistoryViewController



-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    
    
    
    

    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *dataBaseArray = [GMAPI GgetGuiji];
    
    NSLog(@"%s %d",__FUNCTION__,dataBaseArray.count);
    
    for (LRoadClass *model in dataBaseArray) {
        NSLog(@"lroadClass---startName:%@  endName:%@ distance:%@ roadId:%d",model.startName,model.endName,model.distance,model.roadId);
    }
    
    NSArray *dayArray = [GMAPI GgetGuiji];
    
    int count = dataBaseArray.count;
    
    //找出同一天的文章 放到一个数组里
    for (int i = 0; i < count; i++) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        
        for (int j = i+1; j<count; j++) {
            LRoadClass *road1 = dayArray[i];
            LRoadClass *road2 = dayArray[j];
            //判断时间
            if ([[road1.startName substringToIndex:10] isEqualToString:[road2.startName substringToIndex:10]]) {
                //如果相同并且日期 = NO 就加入数组里
                
                NSLog(@"%@",[road1.startName substringToIndex:10]);
                
                if (![road1.startName substringToIndex:10]) {
                    
                    [arr addObject:road1];
                    road1.time = YES;
                }
                
                if (![road2.startName substringToIndex:10]) {
                    
                    [arr addObject:road2];
                    road2.time = YES;
                }
            }
        }
        
        LRoadClass *road1 = dayArray[i];
        if (arr.count == 0 && !road1.time) {//判断一天只有一个文章的情况
            [arr addObject:road1];
        }
        
        if (arr.count > 0) {
            
            [self.dataArray addObject:arr];
            
            NSLog(@"self.dataArray.count : %d",self.dataArray.count);
            
            NSLog(@"arr.count : %d",arr.count);
            
        }
    }
    
    
    
    
    //总公里数 运动次数 时长
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [upGrayView addSubview:titielLabel];
    
    
    [self.view addSubview:upGrayView];
    
    
    //展开的数组
    _fangkaiArray = [NSMutableArray arrayWithCapacity:1];
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, 568) style:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 568) style:UITableViewStylePlain];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    

    
    
    
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    int num = self.dataArray.count;
    
    return num;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}



-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    upHeaderView.tag = section +10;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gShouFangZiRu:)];
    [upHeaderView addGestureRecognizer:tap];
    
    if (section == 0) {
        upHeaderView.frame = CGRectMake(0, 0, 320, 114);
        upHeaderView.backgroundColor = [UIColor whiteColor];
    }else{
        upHeaderView.frame = CGRectMake(0, 0, 320, 30);
        upHeaderView.backgroundColor = RGBCOLOR(190, 190, 190);
    }
    
    return upHeaderView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    if (section == 0) {
        height = 114;
    }else{
        height = 50;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}



-(void)gShouFangZiRu:(UIGestureRecognizer*)ges{
    if (ges.view.tag !=10) {//不是最上面的view
        
        NSString *sectionStr = [NSString stringWithFormat:@"%d",(ges.view.tag-10)];
        
        int arrCount = _fangkaiArray.count;
        BOOL ishave = NO;
        
        for (int i = 0; i<arrCount; i++) {
            NSString *str = _fangkaiArray[i];
            if ([str isEqualToString:sectionStr]) {
                ishave = YES;
                [_fangkaiArray removeObject:str];
            }
        }
        
        if (!ishave || arrCount==0) {
            [_fangkaiArray addObject:sectionStr];
        }
        
        [_tableView reloadData];
        
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
