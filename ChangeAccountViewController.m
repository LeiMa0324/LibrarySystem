//
//  ChangeAccountViewController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "ChangeAccountViewController.h"

@interface ChangeAccountViewController ()

@end

@implementation ChangeAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置view的背景颜色
    [self.view setBackgroundColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0 alpha:1]];
    
    //设置用户名文本框
    self.AccountLabel=[[UITextField alloc] initWithFrame:CGRectMake(30, 240, self.view.frame.size.width-60, 50)];
    self.AccountLabel.backgroundColor=[UIColor whiteColor];
    self.AccountLabel.placeholder=[NSString stringWithFormat:@"   账 户"];
    self.AccountLabel.layer.cornerRadius=10.0;
    [self.view addSubview:self.AccountLabel];
    NSLog(@"%f",self.view.frame.size.width-80);
    
    //设置密码文本框
    self.PwdLabel=[[UITextField alloc] initWithFrame:CGRectMake(30, 300, self.view.frame.size.width-60, 50)];
    self.PwdLabel.backgroundColor=[UIColor whiteColor];
    self.PwdLabel.placeholder=[NSString stringWithFormat:@"   密 码"];
    self.PwdLabel.layer.cornerRadius=10.0;
    [self.view addSubview:self.PwdLabel];
    
    //设置联系方式文本框
    self.TelephoneTextField=[[UITextField alloc] initWithFrame:CGRectMake(30, 360, self.view.frame.size.width-60, 50)];
    self.TelephoneTextField.backgroundColor=[UIColor whiteColor];
    self.TelephoneTextField.placeholder=[NSString stringWithFormat:@"   联系方式"];
    self.TelephoneTextField.layer.cornerRadius=10.0;
    [self.view addSubview:self.TelephoneTextField];
    
    
#pragma mark-增加校验逻辑
    //设置提交按钮
    self.SubmitBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.SubmitBtn setFrame:CGRectMake(30, 500, self.view.frame.size.width-60, 50)];
    [self.SubmitBtn setTitle:@"提  交" forState:UIControlStateNormal];
    [self.SubmitBtn setBackgroundColor:[UIColor whiteColor]];
    self.SubmitBtn.layer.cornerRadius=10.0;   //设置圆角
    
    //设置提交按钮---设置字体大小，颜色，
    self.SubmitBtn.titleLabel.font=[UIFont boldSystemFontOfSize:20.0];
    self.SubmitBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.SubmitBtn setTitleColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1] forState:UIControlStateNormal];
    
    [self.view addSubview:self.SubmitBtn];
    
    
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
