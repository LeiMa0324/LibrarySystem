//
//  BookInfo.h
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/9.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookInfo : NSObject

@property (nonatomic,strong) NSString *BookName;    //书名
@property (nonatomic,strong) NSString *Author;      //作者
@property (nonatomic,strong) NSString *Publisher;   //出版社
@property (nonatomic,strong) NSDate *PublishDate;  //出版时间
@property (nonatomic,strong) NSString *desc;        //图书描述
@property (nonatomic,strong) NSString *AuthNum;     //作者手机
@property (nonatomic,strong) NSString *AuthMail;    //作者邮箱



@end
