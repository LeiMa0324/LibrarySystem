//
//  SignInViewController.h
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

@property (nonatomic,strong) UIButton *SubmitBtn;        //登录按钮
@property (nonatomic,strong) UITextField *AccountLabel; //用户名文本框
@property (nonatomic,strong) UITextField *PwdLabel;     //密码文本框
@property (nonatomic,strong) UITextField *TelephoneTextField;   //联系方式文本框


@end
