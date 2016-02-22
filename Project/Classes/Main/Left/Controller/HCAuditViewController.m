//
//  HCAuditViewController.m
//  Project
//
//  Created by 朱宗汉 on 16/2/19.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import "HCAuditViewController.h"
#import "SCSwipeTableViewCell.h"
@interface HCAuditViewController ()<UITableViewDataSource,UITableViewDelegate,SCSwipeTableViewCellDelegate>{
    NSMutableArray *btnArr;
    UITableView *tabview;
}

@end

@implementation HCAuditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    btnArr = [NSMutableArray array];
    [self setupBackItem];
    [self makeUI];
}
- (void)cellOptionBtnWillShow{
    NSLog(@"cellOptionBtnWillShow");
}

- (void)cellOptionBtnWillHide{
    NSLog(@"cellOptionBtnWillHide");
}

- (void)cellOptionBtnDidShow{
    NSLog(@"cellOptionBtnDidShow");
}

- (void)cellOptionBtnDidHide{
    NSLog(@"cellOptionBtnDidHide");
}
- (void)makeUI{
    tabview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    tabview.delegate = self;
    tabview.dataSource = self;
    [self.view addSubview:tabview];
}
- (void)SCSwipeTableViewCelldidSelectBtnWithTag:(NSInteger)tag andIndexPath:(NSIndexPath *)indexpath{
    NSLog(@"you choose the %ldth btn in section %ld row %ld",(long)tag,(long)indexpath.section,(long)indexpath.row);
    NSString *message = [NSString stringWithFormat:@"you choose the %ldth btn in section %ld row %ld",(long)tag,(long)indexpath.section,(long)indexpath.row ];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"tips"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil, nil];
    [alert show];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"1" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 60, 55)];
    [button setBackgroundColor:[UIColor redColor]];
   
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"2" forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(0, 0, 60, 55)];
    [button2 setBackgroundColor:[UIColor redColor]];
   
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setTitle:@"3" forState:UIControlStateNormal];
    [button3 setFrame:CGRectMake(0, 0, 60, 55)];
    [button3 setBackgroundColor:[UIColor redColor]];
    
    btnArr = [NSMutableArray arrayWithObjects:button,button2,button3, nil];
    static NSString *cellIdentifier = @"Cell";
    SCSwipeTableViewCell *cell = (SCSwipeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Cell"
                                                  withBtns:btnArr
                                                 tableView:tabview];
        cell.delegate = self;
        //[cell.SCContentView addSubview:label];
    }
    
    for (UILabel *subLabel in cell.SCContentView.subviews) {
        subLabel.text = [NSString stringWithFormat:@"swipeCell test row %ld",(long)indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *selected = [tableView indexPathForSelectedRow];
    
    if(selected)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
