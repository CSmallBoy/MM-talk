//
//  HCHomeUserTimeViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/17.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCHomeUserTimeViewController.h"
#import "HCHomeDetailViewController.h"
#import "HCHomePictureDetailViewController.h"
#import "MJRefresh.h"
#import "HCHomeTableViewCell.h"
#import "HCHomeInfo.h"
#import "HCHomeApi.h"
#import "NHCListOfTimeAPi.h"
#import "NHCMySelfTimeListApi.h"

#define HCHomeUserTimeCell @"HCHomeUserTimeCell2"

@interface HCHomeUserTimeViewController ()<HCHomeTableViewCellDelegate>{
    int a;
}

@property (nonatomic, strong) UIBarButtonItem *rightItem;

@end

@implementation HCHomeUserTimeViewController

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated{
    a = 0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    HCHomeInfo *info = self.data[@"data"];
    self.navigationItem.title = [NSString stringWithFormat:@"%@的时光", info.NickName];
    [self setupBackItem];
    [self readLocationData];
    
    self.navigationItem.rightBarButtonItem = self.rightItem;
    
    self.tableView.tableHeaderView = HCTabelHeadView(0.1);
    [self.tableView registerClass:[HCHomeTableViewCell class] forCellReuseIdentifier:HCHomeUserTimeCell];
    //家庭
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestHomeData)];
    //加载更多
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreHomeData)];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HCHomeUserTimeCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.indexPath = indexPath;
    HCHomeInfo *info = self.dataSource[indexPath.section];
    cell.info = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCHomeInfo *info = self.dataSource[indexPath.section];
    HCHomeDetailViewController *detail = [[HCHomeDetailViewController alloc] init];
    detail.data = @{@"data": info};
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat height = 60 + WIDTH(self.view)*0.15;
//    
//    HCHomeInfo *info = self.dataSource[indexPath.section];
//    height = height + [Utils detailTextHeight:info.FTContent lineSpage:4 width:WIDTH(self.view)-20 font:14];
//    if (!IsEmpty(info.FTImages))
//    {
//        height = height + (WIDTH(self.view)-30)/3;
//    }
//    
//    if (!IsEmpty(info.CreateAddrSmall))
//    {
//        height = height + 30;
//    }
//    return height;
//    
    CGFloat height = 60 + WIDTH(self.view)*0.15;
    HCHomeInfo *info = self.dataSource[indexPath.section];
    height = height + [Utils detailTextHeight:info.FTContent lineSpage:4 width:WIDTH(self.view)-20 font:14];
    if (!IsEmpty(info.FTImages))
    {
        if (info.FTImages.count < 5)
        {
            NSInteger row = ((int)info.FTImages.count/3) + 1;
            height += WIDTH(self.view) * 0.33 * row;
        }else
        {
            NSInteger row = ((int)MIN(info.FTImages.count, 9)/3.5) + 1;
            height += WIDTH(self.view) * 0.33 * row;
        }
    }
    if (!IsEmpty(info.CreateAddrSmall))
    {
        height = height + 30;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - HCHomeTableViewCellDelegate

- (void)hcHomeTableViewCell:(HCHomeTableViewCell *)cell indexPath:(NSIndexPath *)indexPath moreImgView:(NSInteger)index
{
    HCHomePictureDetailViewController *pictureDetail = [[HCHomePictureDetailViewController alloc] init];
    pictureDetail.data = @{@"data": self.dataSource[indexPath.section], @"index": @(index)};
    pictureDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pictureDetail animated:YES];
}

#pragma mark - private methods

- (void)readLocationData
{
    NSString *path = [self getSaveLocationDataPath];
    NSArray *arrayData = [NSArray arrayWithContentsOfFile:path];
    if (IsEmpty(arrayData))
    {
        [self requestHomeData];
    }else
    {
        [self.dataSource addObjectsFromArray:[HCHomeInfo mj_objectArrayWithKeyValuesArray:arrayData]];
        [self.tableView reloadData];
    }
}

- (NSString *)getSaveLocationDataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"usertimedata.plist"];
}

- (void)writeLocationData:(NSArray *)array
{
    NSString *path = [self getSaveLocationDataPath];
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    for (NSInteger i = 0; i < array.count; i++)
    {
        HCHomeInfo *info = array[i];
        NSDictionary *dic = [info mj_keyValues];
        [arrayM addObject:dic];
    }
    [arrayM writeToFile:path atomically:YES];
}

- (void)handleRightItem
{
}

#pragma mark - setter or getter

- (UIBarButtonItem *)rightItem
{
    if (!_rightItem)
    {
        _rightItem = [[UIBarButtonItem alloc] initWithImage:OrigIMG(@"time_but_right Sideba_Clock") style:UIBarButtonItemStylePlain target:self action:@selector(handleRightItem)];
    }
    return _rightItem;
}

#pragma mark - network
//获取家庭的时光
- (void)requestHomeDataF{
//    NHCListOfTimeAPi *api = [[NHCListOfTimeAPi alloc]init];
//    [api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id data) {
//        
//    }];

    NHCMySelfTimeListApi *Api = [[NHCMySelfTimeListApi alloc]init];
    Api.MyselfuserID = _userID;
    [Api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id Data) {
        [self.tableView.mj_header endRefreshing];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:Data];
        [self.tableView reloadData];
    }];
}
//加载数据
- (void)requestHomeData
{
    NHCMySelfTimeListApi *Api = [[NHCMySelfTimeListApi alloc]init];
    Api.MyselfuserID = _userID;
    Api.start_num = @"0";
    Api.home_conut = @"10";
    [Api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id Data) {
        [self.tableView.mj_header endRefreshing];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:Data];
        
    //缓存暂时不加
        //[self writeLocationData:Data];
        [self.tableView reloadData];
        
    }];
     _baseRequest = Api;
}
//下啦刷新
- (void)requestMoreHomeData
{
    NHCMySelfTimeListApi *Api = [[NHCMySelfTimeListApi alloc]init];
    Api.MyselfuserID = _userID;
    Api.start_num = [NSString stringWithFormat:@"%d",10 * (a+1)];
    Api.home_conut = [ NSString stringWithFormat:@"%d",10 * (a+2)];
    [Api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id Data) {
        [self.tableView.mj_footer endRefreshing];
        if (resquestStatus == HCRequestStatusSuccess)
        {
            [self.dataSource addObjectsFromArray:Data];
            [self.tableView reloadData];
            a ++;
        }else
        {
            [self showHUDError:message];
        }
    }];
 
}



@end
