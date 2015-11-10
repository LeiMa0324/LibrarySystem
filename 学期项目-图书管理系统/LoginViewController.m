//
//  LoginViewController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //设置view的背景颜色
    [self.view setBackgroundColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0 alpha:1]];
    
    //设置用户名文本框
    self.AccountLabel=[[UITextField alloc] initWithFrame:CGRectMake(30, 280, self.view.frame.size.width-60, 50)];
    self.AccountLabel.backgroundColor=[UIColor whiteColor];
    self.AccountLabel.placeholder=[NSString stringWithFormat:@"   账 户"];
    self.AccountLabel.layer.cornerRadius=10.0;
    [self.view addSubview:self.AccountLabel];
    NSLog(@"%f",self.view.frame.size.width-80);
    
    //设置密码文本框
    self.PwdLabel=[[UITextField alloc] initWithFrame:CGRectMake(30, 340, self.view.frame.size.width-60, 50)];
    self.PwdLabel.backgroundColor=[UIColor whiteColor];
    self.PwdLabel.placeholder=[NSString stringWithFormat:@"   密 码"];
    self.PwdLabel.layer.cornerRadius=10.0;
    [self.view addSubview:self.PwdLabel];
    
    //设置登录按钮
    self.LoginBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.LoginBtn setFrame:CGRectMake(30, 400, self.view.frame.size.width-60, 50)];
    [self.LoginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [self.LoginBtn setBackgroundColor:[UIColor whiteColor]];
    self.LoginBtn.layer.cornerRadius=10.0;   //设置圆角
    
    //设置登录按钮---设置字体大小，颜色，
    self.LoginBtn.titleLabel.font=[UIFont boldSystemFontOfSize:20.0];
    self.LoginBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.LoginBtn setTitleColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1] forState:UIControlStateNormal];

    [self.view addSubview:self.LoginBtn];
    
    //设置InfoLabel
    self.InfoLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 160, self.view.frame.size.width-40, 50)];
    self.InfoLabel.backgroundColor=[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1];
    self.InfoLabel.text=[NSString stringWithFormat:@" 欢迎使用图书管理系统"];
    self.InfoLabel.textAlignment=NSTextAlignmentCenter;
    self.InfoLabel.textColor=[UIColor whiteColor];
    self.InfoLabel.font=[UIFont boldSystemFontOfSize:30.0];//设置字体大小
    self.InfoLabel.layer.cornerRadius=10.0;
    [self.view addSubview:self.InfoLabel];
    
    
    
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
