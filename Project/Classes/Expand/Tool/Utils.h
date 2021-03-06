//
//  Utils.h
//  PMedical
//
//  Created by Vincent on 15-1-13.
//  Copyright (c) 2015年 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

//通过身份证获取生日
+ (NSString *)getBirthdayBy18PaperId:(NSString *) sPaperId;

// 功能:验证身份证是否合法
+ (BOOL)chk18PaperId:(NSString *) sPaperId;

//通过身份证获取性别
+ (NSNumber *)getSexFromIdcard:(NSString *) sPaperId;

//验证手机号码合法性
+ (BOOL)checkPhoneNum:(NSString *)phoneNum;

//验证密码 6-20位数字和字母组成
+ (BOOL)checkPassWord:(NSString *)pwd;

//根据某个日期计算年龄
+ (NSString *)yearOldFormDate:(double)serverStemp;

//  通过身份证号获取年龄
+ (NSInteger)getYearWithIdcard:(NSString *)idcard;

//颜色转换图片
+ (UIImage *)createImageWithColor:(UIColor *)color;

//width范围内 文本的长度
+ (CGFloat)detailTextHeight:(NSString *)text width:(CGFloat)width font:(CGFloat)font;

+ (CGFloat)detailTextHeight:(NSString *)text lineSpage:(CGFloat)space width:(CGFloat)width font:(CGFloat)font;

+ (NSString *)stringWithObject:(id)theData;

// 获取head的头
+ (NSDictionary *)getRequestHeadWithAction:(NSString *)action;

// NSString 转 NSNumber

+ (NSNumber *)getNumberWithString:(NSString *)string;

//  获取设备类型
+ (NSString *)systemModel;

//获取设备版本号
+ (NSString *)getDeviceVersion;

+ (NSString *)networkingStates;

// 将中间的文本转成其他颜色
+ (NSMutableAttributedString *)changeStringColorWithStart:(NSString *)start colorString:(NSString *)colorStr end:(NSString *)end;

// 转换首字符
+ (NSString *)getChineseFirstCharPinyinWithCityStr:(NSString *)cityStr;

+ (NSString *)formatterWithServer:(NSString *)birthdayStr;
+ (NSString *)formatterWithTimeData:(NSString *)time;

+ (NSInteger)getYearWithDob:(NSString *)dobStr;

#pragma mark - 消息类型
#pragma mark - 时间格式

+ (NSString *)getDateStringWithStemp:(double)stemp format:(NSString *)format;
+ (NSString *)getDateStringWithDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)getDateWithString:(NSString *)sdate format:(NSString *)format;
+ (NSString *)transformServerDate:(double)serverStemp;
@end
