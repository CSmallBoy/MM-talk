//
//  HCpromisedNormalImageCell.m
//  Project
//
//  Created by 朱宗汉 on 16/1/6.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import "HCpromisedNormalImageCell.h"
#import "HCLightGrayLineView.h"
@interface HCpromisedNormalImageCell ()<UITextFieldDelegate>
{
    UILabel      * _lable;
    UITextField  * _textField;
    UILabel      *  _blackLabel;
    
}
@end

@implementation HCpromisedNormalImageCell

+(instancetype)CustomCellWithTableView:(UITableView *)tableView
{
    static  NSString *NCellImageID = @"NormalCellImageID";
    HCpromisedNormalImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NCellImageID];
    if (!cell) {
        cell = [[HCpromisedNormalImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NCellImageID];
        [cell addSubviews];
    }
    return cell;
}

#pragma mark --- textFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.textFieldBlock(_textField.text,self.indexPath);
}


#pragma mark --- private method

-(void)addSubviews
{
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    _lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 60, 40)];
    _lable.textAlignment = NSTextAlignmentCenter;
    _lable.textColor = [UIColor blackColor];
    [self addSubview:_lable];
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(60, 2, SCREEN_WIDTH-100, 40)];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.delegate= self;
    [self addSubview:_textField];

    UIImageView  *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 6, 20, 30)];
    
    imageView.image = OrigIMG(@"yihubaiying_but_Pointe");
    [self addSubview:imageView];
    
    HCLightGrayLineView *lineView = [[HCLightGrayLineView alloc]initWithFrame:CGRectMake(60, 43, SCREEN_WIDTH-70, 1)];
    [self addSubview:lineView];

    
}

#pragma mark --- Setter Or Getter

-(void)setTitle:(NSString *)title
{
    _title = title;
    _lable.text = title;
    
    if (_isBlack) {
        [_blackLabel removeFromSuperview];
        _blackLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 2, SCREEN_WIDTH-100, 40)];
        _blackLabel.userInteractionEnabled = YES;

        _blackLabel.textColor = [UIColor blackColor];
        _blackLabel.font = [UIFont systemFontOfSize:15];
        
        [self addSubview:_blackLabel];
    }
    
}

-(void)setDetail:(NSString *)detail
{
    _detail = detail;
    if (_isBlack) {
        _blackLabel.text = detail;
    }
    else
    {
        _textField.placeholder = detail;

    }
}

-(void)setText:(NSString *)text
{
    _text = text;
    _textField.text = text;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
