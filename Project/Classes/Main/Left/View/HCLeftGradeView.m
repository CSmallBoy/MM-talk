                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //
//  HCLeftGradeView.m
//  Project
//
//  Created by 陈福杰 on 15/12/23.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCLeftGradeView.h"
#import "UIButton+WebCache.h"
#import "MyFamilyViewController.h"
//下载头像
#import "NHCDownloadImageApi.h"
@interface HCLeftGradeView(){
    NSDictionary *dicting;
}

@property (nonatomic, strong) UIButton *sofewareSetBtn;
@property (nonatomic, strong) UIImageView *setImgView;
@property (nonatomic, strong) UIImageView *setImgView2;

@end

@implementation HCLeftGradeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    NHCDownloadImageApi *api = [[NHCDownloadImageApi alloc]init];
    api.type = @"0";//0 代表个人
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSString *photostr) {
        if (IsEmpty(photostr)) {
            [_headButton setImage:IMG(@"1.png") forState:UIControlStateNormal];
        }else{
             [_headButton setImage:[readUserInfo image64:photostr] forState:UIControlStateNormal];
        }
       
    }];
    if (self)
    {
        self.backgroundColor = RGB(34, 35, 37);
        [self addSubview:self.gradeHeadButton];
        [self addSubview:self.gradeName];
        [self addSubview:self.headButton];
        [self addSubview:self.nickName];
        [self addSubview:self.sofewareSetBtn];
        [self addSubview:self.familyButton];
       
    }
    return self;
}

#pragma mark - private methods

- (UIButton *)gradeHeadButton
{
    if (!_gradeHeadButton)
    {
        _gradeHeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _gradeHeadButton.tag = HCLeftGradeViewButtonTypeGradeButton;
        _gradeHeadButton.frame = CGRectMake(30, 60, WIDTH(self)*0.7-60, WIDTH(self)*0.3);
        [_gradeHeadButton addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        ViewRadius(_gradeHeadButton, 5);
        
        [_gradeHeadButton sd_setImageWithURL:[NSURL URLWithString:@"http://xiaodaohang.cn/2.jpg"] forState:UIControlStateNormal placeholderImage:OrigIMG(@"publish_picture")];
    }
    return _gradeHeadButton;
}

- (UILabel *)gradeName
{
    if (!_gradeName)
    {
        _gradeName = [[UILabel alloc] initWithFrame:CGRectMake(0, MaxY(self.gradeHeadButton)+20, WIDTH(self)*0.7, 20)];
        _gradeName.textAlignment = NSTextAlignmentCenter;
        _gradeName.textColor = [UIColor whiteColor];
        _gradeName.text = @"班级名称";
    }
    return _gradeName;
}

- (void)handleButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(hcleftGradeViewSelectedButtonType:)])
    {
        [self.delegate hcleftGradeViewSelectedButtonType:(HCLeftGradeViewButtonType)button.tag];
    }
}

#pragma mark - setter or getter

//我的家族
- (UIButton *)familyButton{
    if (!_familyButton) {
        _familyButton = [UIButton buttonWithType:UIButtonTypeCustom];
       [_familyButton addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        [_familyButton setTitle:@"我的家族" forState:UIControlStateNormal];
        _familyButton.frame = CGRectMake(WIDTH(self)*0.2, HEIGHT(self)-130, 120, 40);
        [_familyButton addSubview:self.setImgView2];
        _familyButton.tag = HCLeftGradeViewFamily;
    }
    return _familyButton;
}
//把图片 下载在赋值
- (UIButton *)headButton
{
    if (!_headButton)
    {
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headButton.tag = HCLeftGradeViewButtonTypeHead;
        [_headButton addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        _headButton.frame = CGRectMake(WIDTH(self)*0.2, 0, WIDTH(self)*0.3, WIDTH(self)*0.3);//WIDTH(self)*0.2, 0, 100, 100);//30, 60, WIDTH(self)*0.7-60, WIDTH(self)*0.3
        ViewRadius(_headButton, WIDTH(self)*0.15);
        _headButton.center = CGPointMake(_headButton.center.x, self.center.y+30);
    
        
        NSDictionary *dict = [readUserInfo getReadDic];
        
        if (dict[@"PhotoStr"]==nil) {
            //没有图片的时候显示的默认头像
            [_headButton sd_setImageWithURL:[NSURL URLWithString:@"http://xiaodaohang.cn/3.jpg"] forState:UIControlStateNormal placeholderImage:OrigIMG(@"publish_picture")];
        }else{
            UIImage *image = [readUserInfo image64:dict[@"PhotoStr"]];
            [_headButton setImage:image forState:UIControlStateNormal];
        }
       
    }
    return _headButton;
}

- (UILabel *)nickName
{
    if (!_nickName)
    {
        _nickName = [[UILabel alloc] init];
        _nickName.textColor = [UIColor whiteColor];
        _nickName.frame = CGRectMake(0, MaxY(self.headButton)+10, WIDTH(self)*0.7, 20);
        _nickName.textAlignment = NSTextAlignmentCenter;
         dicting =[readUserInfo getReadDic];
        if (IsEmpty(dicting[@"UserInf"][@"nickName"])) {
            _nickName.text = @"用户昵称";
        }else{
            _nickName.text = dicting[@"UserInf"][@"nickName"];
        }
        
    }
    return _nickName;
}

- (UIButton *)sofewareSetBtn
{
    if (!_sofewareSetBtn)
    {
        _sofewareSetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sofewareSetBtn.tag = HCLeftGradeViewButtonTypeSoftwareSet;
        [_sofewareSetBtn addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
        [_sofewareSetBtn setTitle:@"软件设置" forState:UIControlStateNormal];
        _sofewareSetBtn.frame = CGRectMake(WIDTH(self)*0.2, HEIGHT(self)-80, 120, 40);
        [_sofewareSetBtn addSubview:self.setImgView];
    }
    return _sofewareSetBtn;
}

- (UIImageView *)setImgView
{
    if (!_setImgView)
    {
        _setImgView = [[UIImageView alloc] initWithImage:OrigIMG(@"Settings")];
        _setImgView.frame = CGRectMake(0, 10, 20, 20);
    }
    return _setImgView;
}
- (UIImageView *)setImgView2
{
    if (!_setImgView2)
    {
        _setImgView2 = [[UIImageView alloc] initWithImage:OrigIMG(@"Home")];
        _setImgView2.frame = CGRectMake(0, 10, 20, 20);
    }
    return _setImgView2;
}


@end
