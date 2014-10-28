//
//  HistoryViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "HistoryViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingIndicatorView.h"

#import "GcustomHistoryTableViewCell.h"

#import "GHistoryDetailViewController.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    UITableView *_tableView;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int _currentPage;
    int _numOnePage;//每页几条数据
    
    //上提加载更多
    LoadingIndicatorView *_upMoreView;//上提加载更多
    BOOL _isUpMoreSuccess;//上提加载成功
    BOOL _isupMore;//是否为上提加载更多
    
    
    //请求轨迹数据 count为0 _currentPage不加
    int _guijiCount;

    
    
}
@end

@implementation HistoryViewController



-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    
    
    _currentPage = 1;
    
    //给属性分配内存
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    self.localDataArray = [NSMutableArray arrayWithCapacity:1];
    
    //准备数据
    [self prepareLocalDataAndNetData];
    
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, 568) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    //下拉刷新
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0-_tableView.bounds.size.height, 320, _tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    _currentPage = 1;
    _isupMore = NO;//是否为上提加载
    _isUpMoreSuccess = NO;//上提加载是否成功
    
    
    
    //上提加载更多
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView = [[LoadingIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView.type = 1;
    _upMoreView.hidden = YES;
    [view addSubview:_upMoreView];
    
    _tableView.tableFooterView = view;
    
    
}


//准备本地数据和网络数据
-(void)prepareLocalDataAndNetData{
    
    [self prepareNetDataWithPage:1];
    
    
    
}

//取本地数据
-(void)prepareLocalData{
    self.localDataArray = [NSMutableArray arrayWithArray:[GMAPI GgetGuiji]];
    
    for (LRoadClass *model in self.localDataArray) {
        NSString *localIdStr= [NSString stringWithFormat:@"%d",model.roadId];
        
        if ([localIdStr isEqualToString:model.serverRoadId]) {//已上传
            
        }else{
            [self.netDataArray addObject:model];
        }
    }
    
}



//按日期排序
-(void)paixuWithDateWithArray:(NSMutableArray *)array{//array为融合数组
    
    
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
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GcustomHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GcustomHistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell loadCustomCellWithMoedle:nil];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *dayGuijiArray = _dataArray[indexPath.section];
        [dayGuijiArray removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
    }
}











-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    int num = self.dataArray.count;
    num = 1;
    
    return num;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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



#pragma mark - 请求网络数据
-(void)prepareNetDataWithPage:(int)page{
    
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];//网络获取到得数组
    
    _guijiCount = array.count;
    
    
    //判断有没有更多
    if (array.count <_numOnePage) {
        [_upMoreView stopLoading:3];
    }else{
        [_upMoreView stopLoading:1];
    }
    
    
    //判断是否为上提加载更多
    if (_isupMore) {//是加载更多的话把请求到的文章加到原来的数组中
        [self.netDataArray addObjectsFromArray:(NSArray*)array];
        
        
    }else{//不是上提加载更多
        self.netDataArray = array;
    }
    
    
    _isUpMoreSuccess = YES;//上提加载更多的标志位
    
    
    //有文章再显示上提加载更多
    if (self.netDataArray.count>0) {
        _upMoreView.hidden = NO;
    }else{
        _upMoreView.hidden = YES;
    }

    
    
    //取本地数据
    [self prepareLocalData];
    
    //按照天数排出二维数组
    [self paixuWithDateWithArray:self.netDataArray];
    
    
    //刷新tableview
    [self doneLoadingTableViewData];
    
    
}






#pragma mark - 下拉上提 相关代理

-(void)reloadTableViewDataSource{
    _reloading = YES;
}

-(void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    
}


#pragma mark - EGORefreshTableHeaderDelegate

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    _currentPage = 1;
    _isupMore = NO;
    [self reloadTableViewDataSource];
    [self prepareNetDataWithPage:_currentPage];
    
    
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date];
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    
    if(_tableView.contentOffset.y > (_tableView.contentSize.height - _tableView.frame.size.height+40)&&_isUpMoreSuccess==YES&&[self.dataArray count]>0)
    {
        [_upMoreView startLoading];
        _isupMore = YES;
        if (_guijiCount) {
            _currentPage++;
        }
        
        _isUpMoreSuccess = NO;
        [self prepareNetDataWithPage:_currentPage];
    }
}











-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GHistoryDetailViewController *cc = [[GHistoryDetailViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
