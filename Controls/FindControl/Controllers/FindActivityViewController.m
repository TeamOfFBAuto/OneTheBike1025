//
//  FindActivityViewController.m
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FindActivityViewController.h"
#import "ActivityTableViewCell.h"
#import "AFHTTPRequestOperation.h"
#import "RefreshTableView.h"
#import "ActivityModel.h"
#import "ActivityDetailViewController.h"

@interface FindActivityViewController ()<UITableViewDataSource,RefreshDelegate>
{
    AFHTTPRequestOperation * operation_request;
}


@property(nonatomic,strong)RefreshTableView * myTableView;
@property(nonatomic,strong)NSMutableArray * data_array;;

@property(nonatomic,strong)MBProgressHUD * aHUD;

@end

@implementation FindActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    _titleLabel.text = @"活动";
    
    self.navigationItem.titleView = _titleLabel;
    
    _data_array = [NSMutableArray array];
    
    
    _myTableView = [[RefreshTableView alloc] initWithFrame:CGRectMake(0,0,320,(iPhone5?568:480)) showLoadMore:YES];
    _myTableView.dataSource = self;
    _myTableView.refreshDelegate = self;
    _myTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:_myTableView];
    
    
    [self getData];
    
    _aHUD = [LTools MBProgressWithText:@"正在加载" addToView:self.view];
    _aHUD.mode = MBProgressHUDModeIndeterminate;
    
}

#pragma makrk - 返回按钮
-(void)clickToBack:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 获取活动数据
-(void)getData
{
    NSString * fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/activityAction_queryActListByPage.action?page=%d",_myTableView.pageNum];
    operation_request = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]]];
    
    __weak typeof(self)wself = self;

    
    [operation_request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            
            [wself.aHUD hide:YES];
            
            NSDictionary * allDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"allDic ----  %@",allDic);
            NSString * total = [allDic objectForKey:@"Total"];
            
            if ([total intValue] > wself.data_array.count)
            {
                NSArray * array = [allDic objectForKey:@"Rows"];
                
                if ([array isKindOfClass:[NSArray class]] && array.count > 0)
                {
                    NSArray * temp_array = [array objectAtIndex:0];
                    
                    if (temp_array.count == 0)
                    {
                        wself.myTableView.isHaveMoreData = NO;
                        [wself.myTableView finishReloadigData];
                        return ;
                    }
                    
                    for (NSDictionary * dic in temp_array)
                    {
                        ActivityModel * model = [[ActivityModel alloc] initWithDic:dic];
                        [wself.data_array addObject:model];
                    }
                    
                    [wself.myTableView finishReloadigData];
                }
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [wself.aHUD hide:YES];
        [LTools showMBProgressWithText:@"加载失败" addToView:wself.view];
    }];
    
    [operation_request start];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data_array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"identifier";
    ActivityTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ActivityTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ActivityModel * model = [_data_array objectAtIndex:indexPath.row];
    [cell.header_imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,model.thumbnailUrl]] placeholderImage:nil];
    cell.title_label.text = model.title;
    cell.sub_title_label.text = model.content;
    cell.date_label.text = [NSString stringWithFormat:@"时间:%@-%@",[self timechange:model.beginTime],[self timechange:model.endTime]];
    return cell;
}

#pragma mark - refreshDelegate
- (void)loadNewData
{
    [self getData];
}
- (void)loadMoreData
{
    [self getData];
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    ActivityModel * model = [_data_array objectAtIndex:indexPath.row];
    
    ActivityDetailViewController * detail = [[ActivityDetailViewController alloc] init];
    detail.aId = model.activityId;
    [self.navigationController pushViewController:detail animated:YES];
    
    
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    return 124;
}
- (UIView *)viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

//时间线转化

-(NSString *)timechange:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM月dd日"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
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
