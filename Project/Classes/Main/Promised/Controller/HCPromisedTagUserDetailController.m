//
//  HCTagUserDetailController.m
//  Project
//
//  Created by 朱宗汉 on 16/4/13.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import "HCPromisedTagUserDetailController.h"
#import "HCTagEditContractPersonController.h"
#import "HCPromiedTagWhenMissController.h"

#import "HCNewTagInfo.h"
#import "HCTagUserDetailCell.h"
#import "HCPickerView.h"
#import "HCAvatarMgr.h"

#import "HCTagAddObjectApi.h"
#import "HCInitSendMessageApi.h"
#import "HCContractPersonListApi.h"
#import "HCTagChangeObjectApi.h"

#import "HCTagContactInfo.h"// 联系人模型
#import "HCPromisedMissMessageControll.h"


@interface HCPromisedTagUserDetailController ()<HCPickerViewDelegate>
@property (nonatomic,strong) HCPickerView *datePicker;
@property (nonatomic,strong) NSString *myTitle;
@property (nonatomic,strong) HCNewTagInfo *info;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIView *medicalView;
@property (nonatomic,strong) UIButton *relBtn;// 关系按钮
@property (nonatomic,strong) UIImageView *smallIV;
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong)UIView*blackView;;
@property (nonatomic,strong)UIView *whiteView;

@property (nonatomic,assign) NSInteger index;


@property (nonatomic,strong) NSMutableArray *contactArr;// 联系人数组
@property (nonatomic,strong) NSMutableArray *selectArr;
@property (nonatomic,strong) NSMutableArray *imgArr;
@property (nonatomic,strong) NSArray *relativeArr;
@property (nonatomic,strong) NSMutableArray *tagArr;

@property (nonatomic,strong) NSString* openHealthCard;
@property (nonatomic,assign) BOOL  isHide;
@property (nonatomic,strong) UISwitch *sw;

@end

@implementation HCPromisedTagUserDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // --------------------------发一呼百应---------------------------------
     [self requestContactData];
    self.myTitle = self.data[@"title"];
    self.info = self.data[@"info"];
    [self.view endEditing:YES];
    if (self.info) {
         [self requestData];
    }
    else
    {
         self.title = @"手动输入";
        self.info = [[HCNewTagInfo alloc]init];
    }
    
    self.tableView.tableHeaderView = HCTabelHeadView(0.1);
    [self setupBackItem];
    self.openHealthCard = @"1";

    self.info.openHealthCard = self.openHealthCard;
    
}



#pragma mark --- UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
         return 3;
    }
    else
    {
        return 1;
    }
    
   
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (tableView == self.tableView) {
        if (section == 0) {
            
            return 6;
        }
        else if (section == 1)
        {
            if (_isHide) {
                return 0;
            }
            
            HCNewTagInfo *info = self.info;
            if ([info.openHealthCard isEqualToString:@"0"]) {
                
                return 0;
            }
            
            return 6;
            
            
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 12;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == 0) {
            return 0.1;
        }
        
        return 40;
    }
    else
    {
        return 0.1;
    }

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if ((indexPath.section == 1 && indexPath.row == 3)||
            (indexPath.section == 1 && indexPath.row == 4)||
            (indexPath.section == 1 && indexPath.row == 5)) {
            
            return 88;
            
        }
        else if (indexPath.section == 2 )
        {
            return 230;
        }
        else
        {
            return 44;
        }
    }else
    {
        return 30;
    }
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableView) {
        if (indexPath.section == 2) {
            
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            
            for (int i = 0; i<self.contactArr.count; i++) {
                
                if (i == 0)
                {
                    
                    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 93, 180)];
                    // 添加联系人按钮
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(10, 20, 73, 73);
                    [button setImage:IMG(@"Classinfo_but_plus") forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(addContactPerson:) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:button];
                    
                    // 添加联系人label
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 73, 20)];
                    label.textColor = [UIColor blackColor];
                    label.text = @"添加联系人";
                    label.adjustsFontSizeToFitWidth  = YES;
                    [view addSubview:label];
                    
                    [self.scrollView addSubview:view];
                    
                }
                else
                {
                    HCTagContactInfo *info = self.contactArr[i];
                    
                    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i*93,0 , 93, 180)];
                    
                    // 头像
                    UIImageView *imageIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 73, 73)];
                    
                    NSURL *url = [readUserInfo originUrl:info.imageName :@"contactor"];
                    [imageIV sd_setImageWithURL:url placeholderImage:IMG(@"Head-Portraits")];
                    
                    ViewRadius(imageIV, 73/2);
                    [view addSubview:imageIV];
                    
                    // 姓名label
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 93, 20)];
                    label.textColor = [UIColor blackColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.text = info.trueName;
                    [view addSubview:label];
                    
                    //选中按钮
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(31, 130, 30, 30);

                    [button setImage:IMG(@"buttonNormal") forState:UIControlStateNormal];
        
                    [button addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                    button.tag = 100+i  ;
                    [view addSubview:button];
                    
                    [ self.scrollView addSubview:view];
                    
                    
                }
            }
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 180, SCREEN_WIDTH-40, 40)];
            button.backgroundColor = kHCNavBarColor;
            [button setTitle:@"下一步" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            ViewRadius(button, 5);
            [button addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [cell addSubview:self.scrollView];
            return cell;
            
            
        }
        else
        {
            HCTagUserDetailCell *cell = [HCTagUserDetailCell cellWithTableView:tableView];
            cell.info = self.info;
            cell.image = self.image;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.indexPath = indexPath;

            return cell;
        }
    }
    else
    {
        static NSString *ID  = @"relativeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID ];
        }
        cell.textLabel.text = self.relativeArr[indexPath.row];
        return cell;
    }

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == 1)
        {
            return self.medicalView;
            
        }
        else if (section ==2)
        {
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
            view.backgroundColor = kHCBackgroundColor;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 30)];
            label.textColor = [UIColor blackColor];
            label.text = @"紧急联系人";
            label.adjustsFontSizeToFitWidth = YES;
            [view addSubview:label];
            
            return view;
            
            
        }
    }
    return nil;

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 0 && indexPath.row == 3) {
            
            [self.view endEditing:NO];
            [self.datePicker show];
            
        }
        else  if (indexPath.section == 0  && indexPath.row == 0)
        {
            [self.datePicker removeFromSuperview];
            [self showAlbum];
        }
        else
        {
            [self.datePicker removeFromSuperview];
        }
    }else
    {
         NSString *str = self.relativeArr[indexPath.row];
        [self.relBtn setTitle:str forState:UIControlStateNormal];
        
        [tableView removeFromSuperview];
    }
 
    
}

#pragma mark --- HCPickerViewDelegate

-(void)doneBtnClick:(HCPickerView *)pickView result:(NSDictionary *)result
{
    NSDate *date = result[@"date"];
    self.info.birthDay = [Utils getDateStringWithDate:date format:@"yyyy-MM-dd"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

#pragma mark --- private  mothods

// 点击了选中联系人按钮

-(void)selectBtnClick:(UIButton *)button
{
    UIImage *image = [button imageForState:UIControlStateNormal];
    
    if ([image isEqual:IMG(@"buttonNormal")]) {
        
        
        if (self.selectArr.count == 2)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"只能绑定两个紧急联系人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
        else
        {
            NSInteger index = button.tag-100;
            
             HCTagContactInfo *info = self.contactArr[index];
            [self addSmallView:info index:index];
            
            self.index = index;
           [button setImage:IMG(@"buttonSelected") forState:UIControlStateNormal];
        }
    }
    else
    {
        [button setImage:IMG(@"buttonNormal") forState:UIControlStateNormal];
        NSInteger index = button.tag-100;
        HCNewTagInfo *info = self.contactArr[index];
        [self.selectArr removeObject:info];
    }

}


// 添加小视图
-(void)addSmallView:(HCTagContactInfo *)info index:(NSInteger)index
{
    // 黑色
    _blackView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _blackView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_blackView addGestureRecognizer:tap];
    [self.view addSubview:_blackView];_blackView.alpha = 0.2;
    
    [self.view addSubview:_blackView];
    
    // 白色
    CGFloat viewW = 325/375.0*SCREEN_WIDTH;
    CGFloat viewH = 290/667.0*SCREEN_HEIGHT;
    CGFloat viewY = 200/667.0*SCREEN_HEIGHT;
     _whiteView= [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-viewW)/2,viewY, viewW,viewH )];
    _whiteView.backgroundColor = [UIColor whiteColor];
    ViewRadius(_whiteView, 5);
    [self.view addSubview:_whiteView];
    
    // 头像
    
    CGFloat imgW = 115/375.0*SCREEN_WIDTH;
    CGFloat imgY = 18/667.0*SCREEN_HEIGHT;

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((viewW-imgW)/2, imgY, imgW, imgW)];
   
    imageView.image = self.imgArr[index];

    
    ViewRadius(imageView, imgW/2);
    [_whiteView addSubview:imageView];
    
    // 姓名
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,imgY + imgW +5,viewW, 20)];
    nameLabel.text = info.trueName;
    nameLabel.adjustsFontSizeToFitWidth  = YES;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [_whiteView addSubview:nameLabel];
    
    // 请选择关系按钮;
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(viewW/2-100,imgY + imgW +30 , 200, 30)];
    
    button1.layer.borderColor = kHCBackgroundColor.CGColor;
    button1.layer.borderWidth = 1;
    [button1 setTitle:@"点击选择关系" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.relBtn = button1;
    
    _smallIV = [[UIImageView alloc]initWithFrame:CGRectMake(175, 7, 15, 15)];
    _smallIV.image = IMG(@"list_close");
    [self.relBtn addSubview:_smallIV];
    [self.relBtn addTarget:self action:@selector(relBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_whiteView addSubview:self.relBtn];
    
     // 确定
    CGFloat btnH = 40/667.0 *SCREEN_HEIGHT;
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,viewH-btnH,viewW , btnH);
    button.backgroundColor = kHCNavBarColor;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_whiteView addSubview:button];
    

}
// 点击黑色视图移除 添加的小时图

-(void)tap:(UITapGestureRecognizer *)tap
{
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.blackView removeFromSuperview];
//    [self.whiteView removeFromSuperview];
    
}

-(void)relBtnClick:(UIButton *)button
{
    _smallIV.image = IMG(@"list_open");
    
    
    CGRect rect = [button convertRect:button.bounds toView:self.view];
    
    UITableView *smallTB = [[UITableView alloc]initWithFrame:CGRectMake(rect.origin.x,rect.origin.y, 200, 200) style:UITableViewStyleGrouped];
    smallTB.delegate = self;
    smallTB.dataSource = self;
    [self.view addSubview:smallTB];
    
}

// 点击了确定按钮

-(void)shoreBtnClick:(UIButton *)button
{
    
    if ([self.relBtn.titleLabel.text isEqualToString:@"点击选择关系"]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择关系" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        HCTagContactInfo *info = self.contactArr[self.index];
        info.relative = self.relBtn.titleLabel.text;
        
        [self.selectArr addObject:info];
        
        [self.whiteView removeFromSuperview];
        [self.blackView removeFromSuperview];
    }
    
    
}

// 跳转到 新增紧急联系人界面
-(void)addContactPerson:(UIButton *)buton
{
    HCTagEditContractPersonController *editVC = [[HCTagEditContractPersonController alloc]init];
    
    [self.navigationController pushViewController:editVC animated:YES];
}

// 展示相册
-(void)showAlbum
{
    [self.datePicker remove];
    [self.view endEditing:YES];
    

    [HCAvatarMgr manager].noUploadImage = YES;
    [[HCAvatarMgr manager] modifyAvatarWithController:self completion:^(BOOL result, UIImage *image, NSString *msg){
        if (result)
        {
            self.image = image;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }];


}


// 点击医疗急救卡的
-(void)swClick:(UISwitch *)sw
{
    if (sw.on) {
        self.info.openHealthCard = @"1";
        sw.on = YES;
        _isHide = NO;

        [self.tableView reloadData];
        
    }
    else
    {
        self.info.openHealthCard = @"0";
        sw.on = NO;
        _isHide = YES;
        
        
        [self.tableView reloadData];
        
    }
    
}

// 点击了下一步按钮

-(void)nextBtnClick
{
    
    if (IsEmpty(self.info.trueName)) {
        [self showHUDText:@"请输入姓名"];
        return;
    }
    if (IsEmpty(self.info.sex)) {
        [self showHUDText:@"请输入生日"];
        return;
    }
    if (IsEmpty(self.info.homeAddress)) {
        [self showHUDText:@"请输入住址"];
        return;
    }
    if (IsEmpty(self.info.school)) {
        [self showHUDText:@"请输入学校"];
        return;
    }
    
    if ([self.info.openHealthCard isEqualToString:@"1"]) {
        
        if (IsEmpty(self.info.height)) {
            [self showHUDText:@"请输入身高"];
            return;
        }
        if (IsEmpty(self.info.weight)) {
            [self showHUDText:@"请输入体重"];
            return;
        }
        if (IsEmpty(self.info.bloodType)) {
            [self showHUDText:@"请输入血型"];
            return;
        }
        if (IsEmpty(self.info.allergic)) {
            [self showHUDText:@"请输入过敏史"];
            return;
        }
        if (IsEmpty(self.info.cureCondition)) {
            [self showHUDText:@"请输入医疗状况"];
            return;
        }
        if (IsEmpty(self.info.cureNote)) {
            [self showHUDText:@"请输入医疗笔记"];
            return;
        }
    }

        if (self.selectArr.count== 2) {
           
            
            if (self.tagArr.count>0) {
                HCPromiedTagWhenMissController *vc = [[HCPromiedTagWhenMissController alloc]init];
                vc.info = self.info;
                vc.contactArr = self.selectArr;
                vc.dataArr = self.tagArr;
                [self.navigationController pushViewController:vc animated:YES];
            }else
            {
                
                HCPromisedMissMessageControll*vc = [[HCPromisedMissMessageControll alloc]init];
                vc.info = self.info;
                vc.tagArr = self.tagArr;
                vc.contactArr = self.selectArr;
                [self.navigationController pushViewController:vc animated:YES];
            }    
        }
        else
        {
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"必须选择两个紧急联系人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
}
#pragma mark--- setter Or getter

- (HCPickerView *)datePicker
{
    if (_datePicker == nil)
    {
        _datePicker = [[HCPickerView alloc] initDatePickWithDate:[NSDate date]
                                                  datePickerMode:UIDatePickerModeDate isHaveNavControler:YES];
        _datePicker.datePicker.maximumDate = [NSDate date];
        _datePicker.delegate = self;
    }
    return _datePicker;
}


- (UIScrollView *)scrollView
{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}


- (NSMutableArray *)contactArr
{
    if(!_contactArr){
        _contactArr = [NSMutableArray array];
    }
    return _contactArr;
}


- (NSMutableArray *)selectArr
{
    if(!_selectArr){
        _selectArr = [NSMutableArray array];
    }
    return _selectArr;
}



- (NSMutableArray *)imgArr
{
    if(!_imgArr){
        _imgArr = [NSMutableArray array];
        [_imgArr addObject:@"1"];
    }
    return _imgArr;
}



- (NSArray *)relativeArr
{
    if(!_relativeArr){
        _relativeArr = @[@"曾祖父",@"曾祖母",@"祖父",@"祖母",@"付清",@"母亲",@"兄弟",@"姐妹",@"儿子",@"女儿",@"孙女",@"孙子"];
    }
    return _relativeArr;
}


- (NSMutableArray *)tagArr
{
    if(!_tagArr){
        _tagArr = [NSMutableArray array];
    }
    return _tagArr;
}



- (UIView *)medicalView
{
    if(!_medicalView){
        _medicalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _medicalView.backgroundColor = kHCBackgroundColor;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 30)];
        label.textColor = [UIColor blackColor];
        label.text = @"医疗急救卡";
        label.adjustsFontSizeToFitWidth = YES;
        [_medicalView addSubview:label];
        
        _sw = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 5, 40, 30)];
        

        if (_sw.on) {
            
            _sw.on = NO;
            self.info.openHealthCard = @"0";
        }
        else
        {
           _sw.on = YES;
            self.info.openHealthCard = @"1";
        }
        
        
        [_sw addTarget:self action:@selector(swClick:) forControlEvents:UIControlEventValueChanged];
        [_medicalView addSubview:_sw];
        
    }
    return _medicalView;
}


#pragma mark --- network

// 请求联系人数组
-(void)requestContactData
{
    [self showHUDView:nil];
    HCContractPersonListApi *api = [[HCContractPersonListApi alloc]init];
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id respone) {
        
        if (requestStatus == HCRequestStatusSuccess) {
            [self.contactArr removeAllObjects];
            NSArray *array = respone[@"Data"][@"rows"];
            
            for (NSDictionary *dic in array) {
                HCTagContactInfo *info = [HCTagContactInfo  mj_objectWithKeyValues:dic];
                [self.contactArr addObject:info];
                
                NSURL *url = [readUserInfo originUrl:info.imageName :@"contactor"];
                UIImage *imgFromUrl =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
                if (imgFromUrl == nil) {
                    imgFromUrl = IMG(@"Head-Portraits");
                }
                [self.imgArr addObject:imgFromUrl];
                
            }
            HCTagContactInfo *info = [[HCTagContactInfo alloc]init];
            info.trueName = @"添加联系人";
            [self.contactArr insertObject:info atIndex:0];
            self.scrollView.contentSize = CGSizeMake(93 * self.contactArr.count, 120);
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:2];
            
            [self hideHUDView];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];

}

-(void)requestData
{
    HCInitSendMessageApi *api = [[HCInitSendMessageApi alloc]init];
    
    api.objectId = self.info.objectId;
    
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id respone) {
        
        if (requestStatus == HCRequestStatusSuccess) {
            NSDictionary *dic = respone[@"Data"][@"objectInf"];
            self.info = [HCNewTagInfo mj_objectWithKeyValues:dic];
            self.info.openHealthCard = @"1";
            self.info.openHomeAddress = @"1";
            
            self.title = [NSString stringWithFormat:@"%@的标签",self.info.trueName];
            
            NSArray *array = respone[@"Data"][@"rows"];
            [self.tableView reloadData];
            for (NSDictionary *dic in array) {
                
                HCNewTagInfo *info = [HCNewTagInfo mj_objectWithKeyValues:dic];
                [self.tagArr addObject:info];
            }
        }
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
