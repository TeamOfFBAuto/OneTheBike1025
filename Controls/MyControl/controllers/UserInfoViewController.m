//
//  UserInfoViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoRowCell.h"
#import "UserInfoHeaderCell.h"
#import "UserInfoClass.h"

@interface UserInfoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSArray *titles_arr;
    MBProgressHUD *loading;
    
    UserInfoClass *userInfo;
    
    BOOL haveChange;//判断是否有改变
    
    UserInfoHeaderCell *cell_header;//头像cell
}

@end

@implementation UserInfoViewController

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
    _titleLabel.text = @"个人信息";
    
    self.navigationItem.titleView = _titleLabel;
    
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? - 7 : 7;
    
    UIButton *settings=[[UIButton alloc]initWithFrame:CGRectMake(20,8,40,20)];
    [settings addTarget:self action:@selector(clickToFinish:) forControlEvents:UIControlEventTouchUpInside];
    [settings setTitle:@"完成" forState:UIControlStateNormal];
    [settings.titleLabel setFont:[UIFont systemFontOfSize:12]];
    settings.layer.cornerRadius = 3.f;
    [settings setBackgroundColor:[UIColor colorWithHexString:@"bebebe"]];
    UIBarButtonItem *right =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.rightBarButtonItems = @[spaceButton1,right];
    
    titles_arr = @[@"头像",@"昵称",@"性别",@"签名",@"身高",@"体重"];
    
    loading = [LTools MBProgressWithText:@"加载中" addToView:self.view];
    
    NSString *custId = [LTools cacheForKey:USER_CUSTID];
    
    [self getUserInfoForId:custId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据解析

#pragma mark - 网络请求

- (void)editUserInfo{
    [loading show:YES];
    
    //custId=%@&nickName=%@&sex=%d&cellphone=%@&personSign=%@&height=%@&weight=%@&birthday=%@&city=%@
    
    NSString *custId = [LTools cacheForKey:USER_CUSTID];
    
    NSString *nickName = [self labelForTag:101].text;
    
    NSString *sex = @"";
    if ([[self labelForTag:102].text isEqualToString:@"男"]) {
        
        sex = @"1";
    }else if ([[self labelForTag:102].text isEqualToString:@"女"]){
        
        sex = @"2";
    }
 
    NSString *personSign = [self labelForTag:103].text;
    NSString *height = [self labelForTag:104].text;
    
    height = [height substringToIndex:height.length - 2];
    
    NSString *weight = [self labelForTag:105].text;
    
    weight = [weight substringToIndex:weight.length - 2];
    
    NSString *url = [NSString stringWithFormat:BIKE_EDIT_USERINFO,custId,nickName,sex,@"11",personSign,height,weight,@"2014-01-01",@"11"];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int success = [[result objectForKey:@"status"]integerValue];
        
        if (success == 1) {
            
            NSString *userName = [result objectForKey:@"nickName"];
            
            [LTools cache:userName ForKey:USER_NAME];
            
            [LTools showMBProgressWithText:@"个人资料修改成功" addToView:self.view];
            
            haveChange = NO;
            
            [self clickToBack:nil];
        }
        
        [loading hide:YES];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
        
        [loading hide:YES];
        
        [LTools showMBProgressWithText:@"更新用户信息失败" addToView:self.view];
        
    }];
}


- (void)getUserInfoForId:(NSString *)userId{
    [loading show:YES];
    
    NSString *url = [NSString stringWithFormat:BIKE_USER_INFO,userId];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        userInfo = [[UserInfoClass alloc]initWithDictionary:result];
        
        [LTools cache:userInfo.nickName ForKey:USER_NAME];
        
        [self.tableView reloadData];
        
        [loading hide:YES];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
        
        [loading hide:YES];
        
        [LTools showMBProgressWithText:@"加载失败" addToView:self.view];
        
    }];
}


#pragma mark - 视图创建

#pragma mark- 事件处理

- (void)clickToBack:(UIButton *)sender
{
    if (haveChange) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否保存用户资料" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.tag = 1000;
        
        [alert show];

       
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)labelForTag:(int)tag
{
    UILabel *label = (UILabel *)[self.view viewWithTag:tag];
    return label;
}

- (void)clickToFinish:(UIButton *)sender
{
    [self editUserInfo];
}

- (void)clickToEditTitle:(NSString *)title
             placeHolder:(NSString *)placeHolder
                 message:(NSString *)message
                     tag:(int)tag
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tf = [alert textFieldAtIndex:0];
    
    if (tag == 104 || tag == 105) {
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    
    alert.tag = tag;
    
    [alert show];
    
    tf.placeholder = placeHolder;
    
}

#pragma mark - delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        
        if (buttonIndex == 1) {
            
            //提交资料更改
            
            [self editUserInfo];
        }else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
        return;
    }
    
    
    if (buttonIndex == 1) {
        //确定
        
        haveChange = YES;
        
        UITextField *tf = [alertView textFieldAtIndex:0];
        
        switch (alertView.tag) {
            case 101:
            {
                //昵称
                
                [self labelForTag:101].text = tf.text;
                
            }
                break;
            case 102:
            {
                //性别
                
                if ([tf.text isEqualToString:@"男"] || [tf.text isEqualToString:@"女"]) {
                    [self labelForTag:102].text = tf.text;
                }else
                {
                    [self clickToEditTitle:@"请填写正确性别" placeHolder:@"例如:男" message:@"填写男或女" tag:102];
                }
                
            }
                break;
            case 103:
            {
                //签名
                [self labelForTag:103].text = tf.text;
                
            }
                break;
            case 104:
            {
                //身高
                if ([LTools isValidateFloat:tf.text] || [LTools isValidateInt:tf.text]) {
                    [self labelForTag:104].text = [NSString stringWithFormat:@"%@cm",tf.text];
                }else
                {
                   [self clickToEditTitle:@"请填写有效数字" placeHolder:@"例如:180" message:@"身高以cm为单位" tag:104];
                }
            }
                break;
            case 105:
            {
                //体重
                if ([LTools isValidateFloat:tf.text] || [LTools isValidateInt:tf.text]) {
                    [self labelForTag:105].text = [NSString stringWithFormat:@"%@kg",tf.text];
                }else
                {
                    [self clickToEditTitle:@"请填写有效数字" placeHolder:@"例如:70" message:@"体重以kg为单位" tag:105];

                }
                
            }
                break;
                
            default:
                break;
        }
        
        
        
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 90;
    }
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        //头像
        
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [sheet showInView:self.view];
        
        
    }else if (indexPath.row == 1) {
        
        //昵称
        
        [self clickToEditTitle:@"昵称" placeHolder:@"昵称" message:nil tag:100 + indexPath.row];
        
    }else if (indexPath.row == 2){
        
        //性别
        
        [self clickToEditTitle:nil placeHolder:@"例如:男" message:@"填写男或女" tag:100 + indexPath.row];
        
        
    }else if (indexPath.row == 3){
        //签名
        
        [self clickToEditTitle:@"签名" placeHolder:@"签名" message:nil tag:100 + indexPath.row];
        
    }else if (indexPath.row == 4){
        //身高
        [self clickToEditTitle:nil placeHolder:@"例如:180" message:@"身高以cm为单位" tag:100 + indexPath.row];
        
    }else if (indexPath.row == 5){
        //体重
        
        [self clickToEditTitle:nil placeHolder:@"例如:70" message:@"体重以kg为单位" tag:100 + indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        static NSString * identifier1= @"UserInfoHeaderCell";
        
        cell_header = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell_header == nil) {
            cell_header = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoHeaderCell" owner:self options:nil]objectAtIndex:0];
        }
        cell_header.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
        cell_header.backgroundColor = [UIColor clearColor];
        cell_header.selectionStyle = UITableViewCellSelectionStyleNone;
        cell_header.aTitleLabel.text = [titles_arr objectAtIndex:indexPath.row];
        
//        NSString *head = [LTools cacheForKey:USER_HEAD_IMAGEURL];
//        [cell_header.headImageView sd_setImageWithURL:[NSURL URLWithString:head] placeholderImage:nil];
        
        UIImage *headImage = [LTools getImageForUserId:[LTools cacheForKey:USER_CUSTID]];
        
        if (headImage) {
            
            cell_header.headImageView.image = headImage;
        }else
        {
            cell_header.headImageView.image = [UIImage imageNamed:@"bike_default"];
        }
        
        return cell_header;
        
    }
    
    static NSString * identifier1= @"UserInfoRowCell";
    
    UserInfoRowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoRowCell" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.aTitleLabel.text = [titles_arr objectAtIndex:indexPath.row];
    if (indexPath.row == 1) {
        NSString *nick = [LTools cacheForKey:USER_NAME];
        cell.aDetailLabel.text = nick;
    }else if (indexPath.row == 2){
        
        
        NSLog(@"--->%@",userInfo.sex);
        
        if ([userInfo.sex isEqualToString:@"null"]) {
            
            cell.aDetailLabel.text = @"";
        }else{
            cell.aDetailLabel.text = [userInfo.sex intValue] == 1 ? @"男" : @"女";
        }
        
        
        //性别
    }else if (indexPath.row == 3){
        //签名
        cell.aDetailLabel.text = [self StringNoNull:userInfo.personSign];
        
    }else if (indexPath.row == 4){
        //身高
        
        NSString *height = userInfo.height == nil ? @"" : [NSString stringWithFormat:@"%.1fcm",[userInfo.height floatValue]];
        
        cell.aDetailLabel.text = height;
        
    }else if (indexPath.row == 5){
        //体重
        
        NSString *weight = userInfo.height == nil ? @"" : [NSString stringWithFormat:@"%.1fkg",[userInfo.weight floatValue]];
        cell.aDetailLabel.text = weight;
    }
    
    cell.aDetailLabel.tag = 100 + indexPath.row;
    
    return cell;
    
}

- (NSString *)StringNoNull:(NSString *)str
{
    if ([str isEqualToString:@"null"]) {
        return @"";
    }
    
    if (str.length > 0) {
        return str;
    }
    
    return @"";
}

#pragma - mark imagePicker 代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        //压缩图片 不展示原图
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        UIImage * scaleImage = [self scaleToSizeWithImage:originImage size:CGSizeMake(56, 56)];
        
        NSData *data;
        
        //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
        if (UIImagePNGRepresentation(scaleImage) == nil) {
            //将图片转换为JPG格式的二进制数据
            data = UIImageJPEGRepresentation(scaleImage, 1.0);
        } else {
            //将图片转换为PNG格式的二进制数据
            data = UIImagePNGRepresentation(scaleImage);
        }
        
        //将二进制数据生成UIImage
        UIImage *image = [UIImage imageWithData:data];
        
        
        cell_header.headImageView.image = image;
        
        
        [LTools saveImageToDocWithUserId:[LTools cacheForKey:USER_CUSTID] WithImage:image];
        
        [picker dismissViewControllerAnimated:NO completion:^{
            
            
        }];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)scaleToSizeWithImage:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma - mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        BOOL is =  [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if (is) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"不支持相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }

        
    }else if (buttonIndex == 1){
        
        
        BOOL is =  [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        if (is) {
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"不支持相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
}

@end
