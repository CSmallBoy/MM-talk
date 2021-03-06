//
//  HCUserMessageViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/22.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCUserMessageViewController.h"
#import "HCUserCodeViewController.h"
#import "HCUserHeadImageViewController.h"
#import "HCEditUserMessageViewController.h"

#import "HCUserMessageTableViewCell.h"
#import "HCUserMessageInfo.h"
#import "HCPickerView.h"
#import "NHCUploadImageApi.h"
#import "NHCGetUserHeathApi.h"
#import "NHCDownloadImageApi.h"
#import "HCUserHeathViewController.h"
#import "UIButton+EMWebCache.h"
#define HCUserCell @"HCUserMessageTableViewCell"

@interface HCUserMessageViewController ()<HCPickerViewDelegate,userInfoDelegate>{
    MyselfInfoModel*_model;
    NSArray *arr;
    NSString *str;
    UILabel *label_age;
}

@property (nonatomic, strong) HCPickerView *datePicker;
@property (nonatomic, strong) HCUserMessageInfo *info;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

@property (nonatomic, strong) UIImageView *headBackground;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) UILabel *markLabel;
@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation HCUserMessageViewController
- (void)viewWillAppear:(BOOL)animated{
    _dict = [readUserInfo getReadDic];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headbuttonImage) name:@"changeUserPhoto" object:nil];
    //先判断本地有没有 没有 则是没有上传  自己手机上有没有
    if (IsEmpty(_dict[@"UserInf"][@"imageName"])) {
        if (IsEmpty(_dict[@"PhotoStr"])) {
            [_headButton setBackgroundImage:OrigIMG(@"Head-Portraits") forState:UIControlStateNormal];
        }else{
            [_headButton sd_setBackgroundImageWithURL:[readUserInfo url:_dict[@"PhotoStr"] :kkUser] forState:UIControlStateNormal];
        }
    }else{
        //已经编辑过的
       
        if (IsEmpty(_dict[@"PhotoStr"])) {
            //没有二次以上的编辑
            if (IsEmpty(_dict[@"UserInf"][@"imageName"])) {
                
            }else{
                
                 [_headButton sd_setBackgroundImageWithURL:[readUserInfo url:_dict[@"UserInf"][@"imageName"] :kkUser] forState:UIControlStateNormal];
            }
        }else{
            
             [_headButton sd_setBackgroundImageWithURL:[readUserInfo url:_dict[@"PhotoStr"] :kkUser] forState:UIControlStateNormal];
        }
    }
    //获取健康 信息
    NHCGetUserHeathApi *API= [[NHCGetUserHeathApi alloc]init];
    [API startRequest:^(HCRequestStatus requestStatus, NSString *message, id responseObject) {
        if (requestStatus == HCRequestStatusSuccess) {
            if (IsEmpty(responseObject)) {
                
            }else{
                arr = responseObject;
            }
            
        }
    }];
    [self.tableView reloadData];
 // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photo:) name:@"Photo" object:nil];
}
//-(void)photo:(NSNotification*)userinfo{
//    NSDictionary *dicting1 = userinfo.userInfo;
//    [_headButton sd_setImageWithURL:[readUserInfo url:dicting1[@"PhotoStr"] :kkUser] forState:UIControlStateNormal];
//}
//头像
-(void)headbuttonImage{
    
    NSString *str_url = [readUserInfo getReadDic][@"PhotoStr"];
    
    [_headButton sd_setImageWithURL:[readUserInfo url:str_url :kkUser] forState:UIControlStateNormal];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackItem];
    self.title = @"个人信息";
    self.navigationItem.rightBarButtonItem = self.rightItem;
    _info = [[HCUserMessageInfo alloc] init];
    self.tableView.tableHeaderView = self.headBackground;
    [self.tableView registerClass:[HCUserMessageTableViewCell class] forCellReuseIdentifier:HCUserCell];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCUserMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HCUserCell];
    cell.indexPath = indexPath;
    //    当你上传成功后   服务器没有给返回值智能本地记录上传
    if (IsEmpty(_dict[@"company"])) {
        //有两种可能  一已经完善过  另一种没有完善
        if (IsEmpty(_dict[@"UserInf"][@"company"])) {
            //此种情况下 是没有 完善信息  不操作
            if (indexPath.section==0) {
                switch (indexPath.row) {
                    case 0:{
                        cell.textField.text = _dict[@"UserInf"][@"trueName"];
                        _ture_name = cell.textField.text;
                        
                        
                    }
                        break;
                    case 2:{
                        cell.textField.text = _dict[@"UserInf"][@"sex"];
                        _sex = cell.textField.text;
                    }
                        
                        break;
                    case 4:{
                        cell.textField.text = _dict[@"UserInf"][@"chineseZodiac"];
                        _shuxiang = cell.textField.text;
                    }
                        
                        break;
                    case 3:{
                        cell.textField.text = _dict[@"UserInf"][@"birthDay"];
                        label_age.text = [readUserInfo ageWith:cell.textField.text];
                        _birthday = cell.textField.text;
                    }
                        break;
                    default:
                        break;
                }
                
            }
        }else{
            //此种情况是完善过后  的赋值
            switch (indexPath.row) {
                case 0:
                {
                    cell.textField.text = _dict[@"UserInf"][@"trueName"];
                    _ture_name = cell.textField.text;
                    _headimage = _dict[@"UserInf"][@"imageName"];
                }
                    break;
                case 2:
                {
                    cell.textField.text = _dict[@"UserInf"][@"sex"];
                    _sex = cell.textField.text;
                    
                }
                    break;
                case 3:
                {
                    cell.textField.text = _dict[@"UserInf"][@"birthDay"];
                    label_age.text = [readUserInfo ageWith:cell.textField.text];
                    _birthday = cell.textField.text;
                }
                    break;
                case 4:
                {
                    cell.textField.text = _dict[@"UserInf"][@"chineseZodiac"];
                    _shuxiang = cell.textField.text;
                }
                    break;
                case 5:
                {
                    cell.textField.text = _dict[@"UserInf"][@"homeAddress"];
                    _adress = cell.textField.text;
                }
                    break;
                case 6:
                {
                    cell.textField.text = _dict[@"UserInf"][@"company"];
                    _copany = cell.textField.text;
                    
                }
                    break;
                case 7:
                {
                    cell.textField.text = _dict[@"UserInf"][@"career"];
                    _professional = cell.textField.text;
                    
                }
                    break;
                default:
                    break;
            }

        }
  
    }else{
        switch (indexPath.row) {
            case 0:
            {
                cell.textField.text = _dict[@"UserInf"][@"trueName"];
                _ture_name = cell.textField.text;
                _headimage = _dict[@"PhotoStr"];
            }
                break;
            case 2:
            {
                cell.textField.text = _dict[@"UserInf"][@"sex"];
                _sex = cell.textField.text;
                
            }
                break;
            case 3:
            {
                cell.textField.text = _dict[@"birthday"];
                label_age.text = [readUserInfo ageWith:cell.textField.text];
                _birthday = cell.textField.text;
            }
                break;
            case 4:
            {
                cell.textField.text = _dict[@"chineseZodiac"];
                _shuxiang = cell.textField.text;
                
            }
                break;
            case 5:
            {
                cell.textField.text = _dict[@"adress"];
                _adress = cell.textField.text;
            }
                break;
            case 6:
            {
                cell.textField.text = _dict[@"company"];
                _copany = cell.textField.text;
                
            }
                break;
            case 7:
            {
                cell.textField.text = _dict[@"professional"];
                _professional = cell.textField.text;
            }
                break;
            default:
                break;
        }

    }
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 4)
    {
    }else
    {
        [self.datePicker remove];
    }
    if (indexPath.row == 1)
    {
        HCUserCodeViewController *VC = [[HCUserCodeViewController alloc] init];
        //4.28日
        //VC.head_image = _dict[@"UserInf"][@"imageName"];
        VC.head_image = _headimage;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row==8){
      HCUserHeathViewController * Vc= [[HCUserHeathViewController alloc]init];
        
        if (IsEmpty(arr[0])) {
            Vc.arr_heath = @[@"请输入身高",@"请输入体重",@"请输入血型",@"有无过敏史",@"医疗状况",@"医疗笔记"];
        }else{
            Vc.arr_heath = arr;
        }
        
        [self.navigationController pushViewController:Vc animated:YES];
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

#pragma mark - HCPickerViewDelegate

- (void)doneBtnClick:(HCPickerView *)pickView result:(NSDictionary *)result
{
//    NSDate *date = result[@"date"];
//    HCUserMessageTableViewCell *cell = (HCUserMessageTableViewCell *)
//    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
//    cell.textField.text = [Utils getDateStringWithDate:date format:@"yyyy-MM-dd"];
}

#pragma mark - private methods

- (void)handleRightItem
{
    HCEditUserMessageViewController *editVC = [[HCEditUserMessageViewController alloc]init];
    editVC.delegate = self;
    editVC.ture_name = _ture_name;
    editVC.sex = _dict[@"UserInf"][@"sex"];
    editVC.shuxiang = _shuxiang;
    editVC.birthday = _birthday;
    editVC.adress = _adress;
    editVC.copany = _copany;
    editVC.professional = _professional;
    editVC.headimage = _headimage;
    [self.navigationController pushViewController:editVC animated:YES];
    
}
-(void)userInfoName:(MyselfInfoModel *)model{
   _model  = model;
}
//头像处理
- (void)handleHeadButton
{
    HCUserHeadImageViewController *headImage = [[HCUserHeadImageViewController alloc] init];
    //这个地方需要改
    if (IsEmpty(_dict[@"UserInf"][@"imageName"]))
    {
        if (IsEmpty(_dict[@"PhotoStr"])) {
            headImage.head_image = [readUserInfo imageString:IMG(@"Head-Portraits")];
        }else{
            headImage.head_image = [readUserInfo getReadDic][@"PhotoStr"];
        }
    }else{
        headImage.head_image = [readUserInfo getReadDic][@"UserInf"][@"imageName"];
    }
   // headImage.head_image = [readUserInfo getReadDic][@"UserInf"][@"imageName"];
   
    [self.navigationController pushViewController:headImage animated:YES];
}

#pragma mark - setter 

- (UIBarButtonItem *)rightItem
{
    if (!_rightItem)
    {
        _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(handleRightItem)];
    }
    return _rightItem;
}

- (HCPickerView *)datePicker
{
    if (!_datePicker)
    {
        _datePicker = [[HCPickerView alloc] initDatePickWithDate:[NSDate date]
                                                  datePickerMode:UIDatePickerModeDate isHaveNavControler:YES];
        _datePicker.datePicker.maximumDate = [NSDate date];
        _datePicker.delegate = self;
    }
    return _datePicker;
}

- (UIImageView *)headBackground
{
    if (!_headBackground)
    {
        _headBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), WIDTH(self.view)*0.45)];
        _headBackground.image = OrigIMG(@"2Dbarcode_message_Background");
        _headBackground.userInteractionEnabled = YES;
        label_age = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 50 , 150, 40, 20)];
        label_age.text = @"24岁";
        [_headBackground addSubview:label_age];
        [_headBackground addSubview:self.headButton];
        [_headBackground addSubview:self.nickName];
        [_headBackground addSubview:self.markLabel];
    }
    return _headBackground;
}

- (UIButton *)headButton
{
    if (!_headButton)
    {
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headButton.frame = CGRectMake(0, 30, WIDTH(self.view)*0.2, WIDTH(self.view)*0.2);
        _headButton.center = CGPointMake(self.view.center.x, _headButton.center.y);
      
        
        [_headButton addTarget:self action:@selector(handleHeadButton) forControlEvents:UIControlEventTouchUpInside];
        ViewRadius(_headButton, WIDTH(_headButton)*0.5);
    }
    return _headButton;
}

- (UILabel *)nickName
{
    if (!_nickName)
    {
        _nickName = [[UILabel alloc] initWithFrame:CGRectMake(0, MaxY(self.headButton)+5, WIDTH(self.view), 20)];
        _dict = [readUserInfo getReadDic];
        if (IsEmpty(_dict[@"UserInf"][@"nickName"])) {
            _nickName.text = @"名字昵称";
        }else{
            _nickName.text = _dict[@"UserInf"][@"nickName"];
        }
        
        _nickName.textAlignment = NSTextAlignmentCenter;
        _nickName.textColor = [UIColor whiteColor];
    }
    return _nickName;
}

- (UILabel *)markLabel
{
    if (!_markLabel)
    {
        _markLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MaxY(self.nickName)+5, WIDTH(self.view), 20)];
        _markLabel.textColor = [UIColor whiteColor];
        _markLabel.textAlignment = NSTextAlignmentCenter;
        _markLabel.text = @"To mark each day count.";
        _markLabel.font = [UIFont systemFontOfSize:15];
    }
    return _markLabel;
}



@end
