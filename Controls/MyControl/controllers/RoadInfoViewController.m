//
//  RoadInfoViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RoadInfoViewController.h"
#import "SwitchCell.h"

@interface RoadInfoViewController ()
{
    NSArray *titles_arr;
    NSArray *params_arr;
    MBProgressHUD *loading;
    UIButton *settings2;
}

@end

@implementation RoadInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundImage:NAVIGATION_IMAGE forBarMetrics: UIBarMetricsDefault];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"e3e3e3"];
    
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
    _titleLabel.text = @"详细信息";
    self.navigationItem.titleView = _titleLabel;
    
    UIButton *settings1=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
    [settings1 addTarget:self action:@selector(clickToDelete:) forControlEvents:UIControlEventTouchUpInside];
    [settings1 setTitle:@"删除" forState:UIControlStateNormal];
    [settings1.titleLabel setFont:[UIFont systemFontOfSize:12]];
    settings1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *right1 =[[UIBarButtonItem alloc]initWithCustomView:settings1];
    
    settings2=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
    [settings2 addTarget:self action:@selector(clickToUpload:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right2 =[[UIBarButtonItem alloc]initWithCustomView:settings2];
    settings2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [settings2.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    if (self.aRoad.isUpload) {
        
        [settings2 setTitle:@"已上传" forState:UIControlStateNormal];
        settings2.userInteractionEnabled = NO;

    }else
    {
        [settings2 setTitle:@"上传" forState:UIControlStateNormal];
    }

    self.navigationItem.rightBarButtonItems = @[right2,right1];
    
    titles_arr = @[@"地图上显示",@"起点",@"终点",@"距离"];
    params_arr = @[self.aRoad.startName,self.aRoad.endName,self.aRoad.distance];
    
    loading = [LTools MBProgressWithText:@"路书上传" addToView:self.view];

}

#pragma mark 事件处理


- (void)updateUploadState
{
    if (self.aRoad.isUpload) {
        
        [settings2 setTitle:@"已上传" forState:UIControlStateNormal];
        settings2.userInteractionEnabled = NO;
        
    }else
    {
        [settings2 setTitle:@"上传" forState:UIControlStateNormal];
    }
}

- (void)clickToBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除
- (void)clickToDelete:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
}

//上传
- (void)clickToUpload:(UIButton *)sender
{
    NSLog(@"开始上传");
    
    NSString *startString = [NSString stringWithFormat:@"%f,%f",self.aRoad.startCoor.latitude,self.aRoad.startCoor.longitude];
    
    NSString *endString = [NSString stringWithFormat:@"%f,%f",self.aRoad.endCoor.latitude,self.aRoad.endCoor.longitude];
    
    
    [loading show:YES];
    
    
    [self saveRoadlinesJsonString:self.aRoad.lineString startName:self.aRoad.startName endName:self.aRoad.endName distance:self.aRoad.distance startCoorStr:startString endCoorStr:endString];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex == 0) {
            
            //取消
            
        }else if(buttonIndex == 1){
            
            //删除
            
            BOOL result = [GMAPI deleteRoadId:self.aRoad.roadId type:Type_Road];
            
            if (result) {
                
                [self clickToBack:nil];
            }else
            {
                [LTools showMBProgressWithText:@"删除失败" addToView:self.view];
            }
        }
    }
}

- (void)updateOpenState:(UISwitch *)sender
{
//    [GMAPI updateRoadId:self.aRoad.roadId startName:self.aRoad.startName endName:self.aRoad.endName Open:sender.isOn];
    
    if (sender.isOn) {
        
        [GMAPI updateRoadOpenForId:self.aRoad.roadId];
    }else
    {
        [GMAPI updateRoadCloseForId:self.aRoad.roadId];
    }
    
    self.aRoad.isOpen = sender.isOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

//保存到服务器
- (void)saveRoadlinesJsonString:(NSString *)jsonStr
                      startName:(NSString *)startNameL
                        endName:(NSString *)endNameL
                       distance:(NSString *)totalDistanceL
                   startCoorStr:(NSString *)startString
                     endCoorStr:(NSString *)endString
{
    NSString *custId = [LTools cacheForKey:USER_CUSTID];
    
    NSString *post = [NSString stringWithFormat:@"&roadlines=%@",jsonStr];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url = [NSString stringWithFormat:BIKE_ROAD_LINE,custId,startNameL,@"middle",endNameL,startString,@"wayCoordinates",endString,totalDistanceL];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int status = [[result objectForKey:@"status"]integerValue];
        
        if (status == 1) {
            
            [loading hide:YES];
            
            [LTools showMBProgressWithText:@"路书上传成功" addToView:self.view];
            
            self.aRoad.isUpload = YES;
            
            [self updateUploadState];
            
            NSString * serverRoadId = [result objectForKey:@"rdbkId"];
            
            [GMAPI updateRoadId:self.aRoad.roadId serverRoadId:serverRoadId isUpload:YES];
                        
        }else
        {
            
        }
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,[failDic objectForKey:@"ERRO_INFO"]);
        
        [loading hide:YES];
        
        [LTools showMBProgressWithText:[failDic objectForKey:@"ERRO_INFO"] addToView:self.view];
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return titles_arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        static NSString * identifier1= @"SwitchCell";
        
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SwitchCell" owner:self options:nil]objectAtIndex:0];
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.aTitlteLabel.text = [titles_arr objectAtIndex:indexPath.row];
        cell.switchBtn.on = self.aRoad.isOpen;
        
        [cell.switchBtn addTarget:self action:@selector(updateOpenState:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    static NSString *identify2 = @"nornalcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify2];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify2];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [titles_arr objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [params_arr objectAtIndex:indexPath.row - 1];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}



#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        
        NSString *title = [params_arr objectAtIndex:indexPath.row - 1];
        CGFloat aHeight = [LTools heightForText:title width:250 font:14];
        
        return 44 + aHeight;
        
    }
    
    return 44;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
