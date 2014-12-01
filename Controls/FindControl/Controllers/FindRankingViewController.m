//
//  FindRankingViewController.m
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FindRankingViewController.h"
#import "RankingFunctionView.h"
#import "RankingTableViewCell.h"
#import "RefreshTableView.h"
#import "AFHTTPRequestOperation.h"
#import "RankingModel.h"

@interface FindRankingViewController ()<UITableViewDataSource,RefreshDelegate>
{
    
    
    AFHTTPRequestOperation * af_operation;
}


@property(nonatomic,assign)int day_currentPage;
@property(nonatomic,assign)int week_currentPage;
@property(nonatomic,assign)int month_currentPage;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,strong)NSMutableArray * data_array;
@property(nonatomic,strong)RefreshTableView * myTableView;
@end

@implementation FindRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _day_currentPage = 1;
    _week_currentPage = 1;
    _month_currentPage = 1;
    _currentPage = 1;
    _data_array = [NSMutableArray arrayWithObjects:[NSMutableArray array],[NSMutableArray array],[NSMutableArray array],nil];
    
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
    _titleLabel.text = @"排行";
    
    self.navigationItem.titleView = _titleLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    RankingFunctionView * fView = [[[NSBundle mainBundle] loadNibNamed:@"RankingFunctionView" owner:self options:nil] objectAtIndex:0];
    fView.frame = CGRectMake(0,64,320,30);
    [self.view addSubview:fView];
    
    __weak typeof(self) wself = self;
    [fView setRankingBlock:^(int index) {
        ///index(1今日排行，2本周排行，3本月排行)
        
        if (index == wself.currentPage) {
            return ;
        }else
        {
            wself.currentPage = index;
            
            if ([[wself.data_array objectAtIndex:wself.currentPage-1] count] > 0) {
                [wself.myTableView reloadData];
                return;
            }
            [wself getData];
        }
    }];
    
    _myTableView = [[RefreshTableView alloc] initWithFrame:CGRectMake(0,64+30,320,(iPhone5?568:480)-30-64) showLoadMore:YES];
    _myTableView.refreshDelegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:_myTableView];
    
    [self getData];
}

#pragma mark - 获取数据
-(void)getData
{
    NSString * fullUrl = @"";
    
    if (_currentPage == 1)//今日排行
    {
        fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/cyclingAction_topCycData.action?type=%@&page=%d",@"day",_day_currentPage];
    }else if (_currentPage == 2)//本周排行
    {
        fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/cyclingAction_topCycData.action?type=%@&page=%d",@"week",_week_currentPage];
    }else if (_currentPage ==3)//本月排行
    {
        fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/cyclingAction_topCycData.action?type=%@&page=%d",@"month",_month_currentPage];
    }
    
    NSLog(@"fullUrl ---  %@",fullUrl);
    
    __weak typeof(self)wself = self;
    
    af_operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]]];
    
    [af_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            if (wself.day_currentPage == 1) {
                [[wself.data_array objectAtIndex:0] removeAllObjects];
            }else if (wself.week_currentPage == 1)
            {
                [[wself.data_array objectAtIndex:1] removeAllObjects];
            }else if (wself.month_currentPage == 1)
            {
                [[wself.data_array objectAtIndex:2] removeAllObjects];
            }
            
            NSDictionary * allDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            
            NSLog(@"allDic -----  %@",allDic);
            
            NSArray * array = [allDic objectForKey:@"Rows"];
            if ([array isKindOfClass:[NSArray class]])
            {
                if ([[wself.data_array objectAtIndex:wself.currentPage-1] count] == [[allDic objectForKey:@"Total"] intValue] || [[allDic objectForKey:@"Total"] intValue] == 0)
                {
                    wself.myTableView.isHaveMoreData = NO;
                    [wself.myTableView finishReloadigData];
                    return ;
                }else
                {
                    wself.myTableView.isHaveMoreData = YES;
                }
            }
            
            for (NSDictionary * dic in array)
            {
                RankingModel * model = [[RankingModel alloc] initWithDic:dic];
                [[wself.data_array objectAtIndex:wself.currentPage-1] addObject:model];
            }
            [wself.myTableView finishReloadigData];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [af_operation start];
}

-(void)clickToBack:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_data_array objectAtIndex:_currentPage-1] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"identifier";
    RankingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RankingTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RankingModel * model = [[self.data_array objectAtIndex:_currentPage-1] objectAtIndex:indexPath.row];
    
    cell.ranking_num.text = model.rowid;
    cell.username_label.text = model.nickName;
    [cell.header_imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,model.headPhoto]] placeholderImage:nil];
    cell.distance_label.text = [NSString stringWithFormat:@"里程:%.2fKm",[model.sumCyclingKm floatValue]];
    
    return cell;
}


#pragma mark - RefreshDelegate
- (void)loadNewData
{
    if (_currentPage == 1) {
        _day_currentPage = 1;
    }else if (_currentPage == 2)
    {
        _week_currentPage = 1;
    }else if (_currentPage == 3)
    {
        _month_currentPage = 1;
    }
    [self getData];
}
- (void)loadMoreData
{
    if (_currentPage == 1) {
        _day_currentPage++;
    }else if (_currentPage == 2)
    {
        _week_currentPage++;
    }else if (_currentPage == 3)
    {
        _month_currentPage++;
    }
    [self getData];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}
- (UIView *)viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - dealloc
-(void)dealloc
{
    [af_operation cancel];
    af_operation = nil;
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
