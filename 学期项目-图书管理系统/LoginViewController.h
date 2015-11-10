//
//  LoginViewController.h
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic,strong) UIButton *LoginBtn;        //登录按钮
@property (nonatomic,strong) UITextField *AccountLabel; //用户名文本框
@property (nonatomic,strong) UITextField *PwdLabel;     //密码文本框
@property (nonatomic,strong) UILabel *InfoLabel;    //简介Label

@end
