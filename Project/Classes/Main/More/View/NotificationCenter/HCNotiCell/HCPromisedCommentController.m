//
//  HCPromisedCommentController.m
//  Project
//
//  Created by 朱宗汉 on 16/2/1.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

// -----------------------发现线索 控制器----------------------------


#import "HCPromisedCommentController.h"
#import "ZLPhotoPickerViewController.h"
#import "HCPromisedCommentScanCell.h"

#import "HCPromisedCommentCell.h"
#import "HCPromisedSubCommentCell.h"

#import "HCPromisedCommentFrameInfo.h"
#import "HCPromisedCommentInfo.h"

#import "HCAvatarMgr.h"
#import "ZLPhotoAssets.h"
#import "YTKNetworkAgent.h"
#import "MBProgressHUD.h"

#import "HCCommentListApi.h"
#import "HCReplyLineApi.h"

@interface HCPromisedCommentController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSInteger   _photoCount;
    UIButton  * _addPhotoBtn;
    CGRect      _startFrame;
    BOOL        _startEdit;
    CGFloat     _JianpanH;
    BOOL        _isSelfID;
   
}

@property (nonatomic,strong) UIView        *inputView;
@property (nonatomic,strong) UIView        * photoView;
@property (nonatomic,strong) UIButton      *imageBtn;
@property (nonatomic,strong) UIButton      *sendBtn;
@property (nonatomic,strong) UITableView   *myTableView;
@property (nonatomic,strong) UITextField   *textField;
@property (nonatomic,strong) UITextField      *inputViewText;
@property (nonatomic,strong) NSIndexPath   *subIndexPath;

@property (nonatomic,assign) CGFloat       oldJianpanH;
@property (nonatomic,assign) BOOL          isFirst;

@property (nonatomic,strong) UIView * navView;// 假导航
@property (nonatomic,strong) UIView *statusBarView;// 状态栏


@property (nonatomic,strong) NSMutableArray    *images;

@property (nonatomic,strong) NSString     * mySelfId;;
@property (nonatomic,strong) NSString     * toID;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *imgStrArr;

@property  (nonatomic,strong)  UIScrollView * Clearview;

@property  (nonatomic,strong)  UITableView *smallTableView;

@end

@implementation HCPromisedCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kHCBackgroundColor;
    self.title = @"发现线索";
    _photoCount = 0;
    [self requestData];
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    
    _Clearview  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    _Clearview.scrollEnabled = NO;
    [_Clearview addSubview:self.inputView];
    [self.view addSubview:_Clearview];
    [self.view addSubview:self.myTableView];
    
    
    [self setupBackItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.isFirst = YES;
    
    
}

-(void)customBtnClick:(UIButton *)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    self.myTableView.frame = CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-40-y-64);
   
    
    NSLog(@"------------------%f---------------",y);
}

// 键盘收起来
- (void)keyboardWillHide:(NSNotification *)notif {
 self.myTableView.frame = CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT-40-64);
}


#pragma mark --- tableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCPromisedCommentFrameInfo *frameInfo = self.dataSource[indexPath.row];
    HCPromisedCommentInfo *info = frameInfo.commentInfo;
    
    if ([info.isScan isEqualToString:@"1"]) {
        
        HCPromisedCommentScanCell *cell = [HCPromisedCommentScanCell CellWithTableView:tableView];
        cell.info = info;
        return cell;
    }
    else
    {
        if ([info.toId isEqualToString:self.mySelfId]) {
            HCPromisedCommentCell *cell = [HCPromisedCommentCell cellWithTableView:tableView];
            cell.indexPath = indexPath;
            cell.block = ^(UIButton *button){
                
                if (_startEdit)
                {
                    [self.view endEditing:YES];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                    }completion:^(BOOL finished) {
                        [self.photoView removeFromSuperview];
                    }];
                }else
                {
                    UIImageView *imageview = button.subviews[1];
                    _startFrame = [imageview convertRect:imageview.bounds toView:self.view];
                    UIImageView *selfIV = [[UIImageView alloc]initWithFrame:_startFrame];
                    selfIV.image = imageview.image;
                    selfIV.backgroundColor = [UIColor blackColor];
                    selfIV.userInteractionEnabled = YES;
                    
                    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeBigImageView:)];
                    [selfIV addGestureRecognizer:tap];
                    selfIV.contentMode = UIViewContentModeScaleAspectFit;
                    [self.view addSubview:selfIV];
                    self.navigationController.navigationBarHidden = YES;
                    [UIView animateWithDuration:0.4 animations:^{
                        
                        selfIV.frame = self.view.frame;
                        
                    }];
                }
            };
            cell.subBlock = ^(NSIndexPath *indexPath1){
                
                [self.textField becomeFirstResponder];
                self.subIndexPath = indexPath1;
            };
            
            cell.commnetFrameInfo = self.dataSource[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            HCPromisedSubCommentCell *cell = [HCPromisedSubCommentCell cellWithTableView:tableView];
            cell.commnetFrameInfo = frameInfo;
            cell.indexPath = indexPath;
            cell.subBlock = ^(NSIndexPath *indexPath1){
                
                [self.textField becomeFirstResponder];
                self.subIndexPath = indexPath1;
            };
            cell.block = ^(UIButton *button){
                
                if (_startEdit)
                {
                    [self.view endEditing:YES];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                    }completion:^(BOOL finished) {
                        [self.photoView removeFromSuperview];
                    }];
                }else
                {
                    UIImageView *imageview = button.subviews[1];
                    _startFrame = [imageview convertRect:imageview.bounds toView:self.view];
                    UIImageView *selfIV = [[UIImageView alloc]initWithFrame:_startFrame];
                    selfIV.image = imageview.image;
                    selfIV.backgroundColor = [UIColor blackColor];
                    selfIV.userInteractionEnabled = YES;
                    
                    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeBigImageView:)];
                    [selfIV addGestureRecognizer:tap];
                    selfIV.contentMode = UIViewContentModeScaleAspectFit;
                    [self.view addSubview:selfIV];
                    self.navigationController.navigationBarHidden = YES;
                    [UIView animateWithDuration:0.4 animations:^{
                        
                        selfIV.frame = self.view.frame;
                        
                    }];
                }
            };
            
            cell.subBlock = ^(NSIndexPath *indexPath1){
                
                [self.textField becomeFirstResponder];
                self.subIndexPath = indexPath1;
            };
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }

    }
        
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCPromisedCommentFrameInfo *frameCell = self.dataSource[indexPath.row];
    
    HCPromisedCommentInfo *info = frameCell.commentInfo;
    if ([info.isScan isEqualToString:@"1"]) {
        return 130;
    }
    
    return frameCell.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }completion:^(BOOL finished) {
       [self.photoView removeFromSuperview];
    }];
    
}

#pragma mark --- textFieldDelegate



-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _startEdit = YES;
    for (UIView *view in self.photoView.subviews)
    {
        [self.images removeAllObjects];
        [view removeFromSuperview];
    }
    
    
    [self.photoView removeFromSuperview];
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _startEdit = NO;
   
}

#pragma mark ---- UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            [[picker navigationBar] setTintColor:[UIColor whiteColor]];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
            
        case 1:
        {
            ZLPhotoPickerViewController *zlpVC = [[ZLPhotoPickerViewController alloc]init];
            zlpVC.callBack = ^(NSArray *arr){
                
                for (ZLPhotoAssets *zl in arr)
                {
                    UIImage  *image = zl.originImage;
                    [self.images addObject:image];
                }
                for (int i = 0; i< self.images.count; i++)
                {
                    UIImageView  *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+i * SCREEN_WIDTH/3, 10, SCREEN_WIDTH/3-20, SCREEN_WIDTH/3-20)];
                    imageView.userInteractionEnabled = YES;
                    imageView.image = self.images[i];
                    UILongPressGestureRecognizer  *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deletePhoto:)];
                    [imageView addGestureRecognizer:longPress];
                    imageView.tag = 100+i;
                    [self.photoView addSubview:imageView];
                }
                [UIView animateWithDuration:0.05 animations:^{
                    
                    self.view.bounds = CGRectMake(0,SCREEN_WIDTH/3, SCREEN_WIDTH, SCREEN_HEIGHT);
                    
                }completion:^(BOOL finished) {
                    
                    [self.view addSubview:self.photoView];
                }];
            };
            [self presentViewController:zlpVC animated:YES completion:nil];
        }
            break;
        default:
            break;
       }

}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.images addObject: image];
    
    for (int i = 0; i< self.images.count; i++)
    {
        UIImageView  *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+i * SCREEN_WIDTH/3, 10, SCREEN_WIDTH/3-20, SCREEN_WIDTH/3-20)];
        imageView.image = self.images[i];
        [self.photoView addSubview:imageView];
    }
    
    [UIView animateWithDuration:0.05 animations:^{
        
        self.view.bounds = CGRectMake(0,SCREEN_WIDTH/3, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }completion:^(BOOL finished) {
        
        [self.view addSubview:self.photoView];
        
    }];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+SCREEN_WIDTH/3 * (_photoCount-1), 10,  SCREEN_WIDTH/3-20, SCREEN_WIDTH/3-30)];
    imageView.image = image;
    [self.photoView addSubview:imageView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark --- private mothods


-(void)deletePhoto:(UILongPressGestureRecognizer *)longPress
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH/3-40,0, 20, 20);
    button.backgroundColor = [UIColor  redColor];
    [button addTarget:self action:@selector(smallBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [longPress.view addSubview:button];
}

-(void)smallBtnClick:(UIButton *)btn
{
    UIView *view = btn.superview;
    
    NSInteger index = view.tag-100;
    [self.images removeObjectAtIndex:index];
    
    for (UIView *view in self.photoView.subviews)
    {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i< self.images.count; i++)
    {
        UIImageView  *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+i * SCREEN_WIDTH/3, 10, SCREEN_WIDTH/3-20, SCREEN_WIDTH/3-20)];
        imageView.userInteractionEnabled = YES;
        imageView.image = self.images[i];
        UILongPressGestureRecognizer  *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deletePhoto:)];
        [imageView addGestureRecognizer:longPress];
        imageView.tag = 100+i;
        [self.photoView addSubview:imageView];
    }
    
    if (self.images.count == 0)
    {
        [self.photoView removeFromSuperview];
        self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
}


-(void)removeBigImageView:(UITapGestureRecognizer *)tap
{
    self.navigationController.navigationBarHidden = NO;
    UIImageView *imageView = (UIImageView *)tap.view;
    imageView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.4 animations:^{
        imageView.frame = _startFrame;
    }completion:^(BOOL finished) {
        imageView.contentMode = UIViewContentModeScaleToFill;
        [imageView removeFromSuperview];
    }];

}

-(void)clickImageBtn:(UIButton *) button
{
    UIActionSheet  *sheet = [[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册选取", nil];
    [sheet  showInView:self.view];
    [self.textField endEditing:YES];


}

//添加图片
-(void)addPhoto:(UIButton *)button
{
    UIActionSheet  *sheet = [[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册选取", nil];
    [sheet  showInView:self.view];
}

// 点击了发送按钮
-(void)sendBtnClick:(UIButton *)button
{
    
    
    if (self.textField == nil && self.images.count==0) {
        
        [self showHUDView:@"请输入文字或者上传图片"];
        return;
        
    }
    
    if (self.images.count>0) {
        // 先上传图片
        [self upLoadImages:1];
        
    }
    else
    {
        [self upLoadData];
    }
    
    

}

#pragma mark --- getter Or setter

- (UIView *)inputView
{
    if(!_inputView){
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44-64, SCREEN_WIDTH, 44)];
        _inputView.backgroundColor = kHCNavBarColor;
        [_inputView addSubview:self.sendBtn];
        [_inputView addSubview:self.textField];
        [_inputView addSubview:self.imageBtn];
    }
    return _inputView;
}


- (UITableView *)myTableView
{
    if(!_myTableView){
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStyleGrouped];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
    }
    return _myTableView;
}


- (UITableView *)smallTableView
{
    if(!_smallTableView){
        _smallTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64 , SCREEN_WIDTH, SCREEN_HEIGHT-64-44-_JianpanH) style:UITableViewStyleGrouped];
        _smallTableView.delegate = self;
        _smallTableView.dataSource = self;
    }
    return _smallTableView;
}


- (UITextField *)textField
{
    if(!_textField){
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(60,7,SCREEN_WIDTH-120, 30)];
        _textField.backgroundColor = [UIColor whiteColor];
        ViewRadius(_textField, 4);
        _textField.delegate = self;
    }
    return _textField;
}

- (UIButton *)sendBtn
{
    if(!_sendBtn){
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 2, 60, 40);
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    }
    return _sendBtn;
}

- (UIButton *)imageBtn
{
    if(!_imageBtn){
        _imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageBtn.frame = CGRectMake(10,7 , 30, 30);
        [_imageBtn addTarget:self action:@selector(clickImageBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_imageBtn setBackgroundImage:IMG(@"cam-0") forState:UIControlStateNormal];
    }
    return _imageBtn;
}

- (UIView *)photoView
{
    if(!_photoView){
        _photoView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT,SCREEN_WIDTH, SCREEN_WIDTH/3)];
        _photoView.backgroundColor = [UIColor whiteColor];
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside ];
        button.frame = CGRectMake(0, 0, SCREEN_WIDTH/3, SCREEN_WIDTH/3);
        [button setImage:IMG(@"Classinfo_but_plus") forState:UIControlStateNormal];
        _addPhotoBtn = button;
        [_photoView addSubview:_addPhotoBtn];
    }
    return _photoView;
}

- (NSMutableArray *)images
{
    if(!_images){
        _images = [[NSMutableArray alloc]init];
    }
    return _images;
}


- (NSMutableArray *)dataSource
{
    if(!_dataSource){
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}


- (NSMutableArray *)imgStrArr
{
    if(!_imgStrArr){
        _imgStrArr = [NSMutableArray array];
    }
    return _imgStrArr;
}



- (UITextField *)inputViewText
{
    if(!_inputViewText){
        _inputViewText = [[UITextField alloc]initWithFrame:CGRectMake(10,7,SCREEN_WIDTH-120, 30)];
        _inputViewText.backgroundColor = [UIColor whiteColor];
        ViewRadius(_textField, 4);
        _inputViewText.delegate = self;
        _inputViewText.backgroundColor = [UIColor yellowColor];
    }
    return _inputViewText;
}



#pragma mark ---  network

-(void)requestData
{
    
    
    HCCommentListApi *api = [[HCCommentListApi alloc]init];
    api.callId = self.callId;
    
    api._start = @"0";
    api._count = @"20";
    
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id respone) {
       
        if (requestStatus == HCRequestStatusSuccess) {
            
            [self.dataSource removeAllObjects];
            
            NSArray *array = respone[@"Data"][@"rows"];
            
            NSDictionary *dic = [array lastObject];
            HCPromisedCommentInfo *info = [HCPromisedCommentInfo mj_objectWithKeyValues:dic];
            self.mySelfId = info.toId;
            
            for (NSDictionary *dic in array) {
                
                
                 HCPromisedCommentFrameInfo *frameInfo = [[HCPromisedCommentFrameInfo alloc]init];
                HCPromisedCommentInfo *info = [HCPromisedCommentInfo mj_objectWithKeyValues:dic];
                info.oldId = self.mySelfId;
                frameInfo.commentInfo = info;
                
                [self.dataSource addObject:frameInfo];
                
            }
            
            
            
            
            
            [self.myTableView reloadData];
        }
        
    }];
}

-(void)upLoadData
{
    [self showHUDView:@"发送中"];
    
    HCReplyLineApi *api = [[HCReplyLineApi alloc]init];
    
    HCPromisedCommentInfo *info = [[HCPromisedCommentInfo alloc]init];
    NSString *str = [self.imgStrArr componentsJoinedByString:@","];
    
    info.imageNames = str;
    info.content = self.textField.text;
    
    if (self.subIndexPath) {
        HCPromisedCommentFrameInfo *frameInfo = self.dataSource[self.subIndexPath.row];
        HCPromisedCommentInfo *info1 = frameInfo.commentInfo;
        info.toId = info1.fromId;
    }
    else
    {
       info.toId = @"";
    }

    
    api.info = info;
    api.callId = self.callId;
    
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id responseObject) {
        
        if (requestStatus == HCRequestStatusSuccess) {
            
            [self hideHUDView];
            NSLog(@"评论成功");
            self.textField.text = nil;
            self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            
            self.subIndexPath = nil;
            [self requestData];
        }
        
    }];
}

-(void)upLoadImages:(int)num
{
    if (num > self.images.count) {
        
        [self upLoadData];
        
        return;
    }
    UIImage *image = self.images[num-1];
    NSString *token = [HCAccountMgr manager].loginInfo.Token;
    NSString *uuid = [HCAccountMgr manager].loginInfo.UUID;
    NSString *str = [kUPImageUrl stringByAppendingString:[NSString stringWithFormat:@"fileType=%@&UUID=%@&token=%@",kkUser,uuid,token]];
    [KLHttpTool uploadImageWithUrl:str image:image success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        NSString *imgStr = responseObject[@"Data"][@"files"][0];
        [self.imgStrArr addObject:imgStr];
        int newNum = num +1;
        [self upLoadImages:newNum];
    
    } failure:^(NSError *error) {
        [self showHUDError:@"图片上传失败"];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



@end
