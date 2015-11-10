//
//  EditBookViewController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "EditBookViewController.h"
#define delta 50

@interface EditBookViewController ()

@end

@implementation EditBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置view的背景颜色
    [self.view setBackgroundColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0 alpha:1]];
    
    
    //设置书名TextField
    self.BooknameText=[[UITextField alloc]init];
    CGFloat bookX=(self.view.frame.size.width-300)*0.5;   //书名TextField的位置X
    CGFloat bookY=self.view.frame.origin.y+100;   //书名TextField的位置Y
    CGRect bookframe=CGRectMake(bookX, bookY, 300, 30); //书名 长宽高
    self.BooknameText.frame=bookframe;
    self.BooknameText.backgroundColor=[UIColor whiteColor];
    self.BooknameText.layer.cornerRadius=5.0;
    self.BooknameText.placeholder=@" 书名";
    
    [self.view addSubview:self.BooknameText];  //加入view中
    
    
    //设置书的描述TextField
    self.BookInfoText=[[UITextField alloc]init];
    CGFloat bookinfoX=bookX;   //书名TextField的位置X
    CGFloat bookinfoY=bookY+delta;   //书名TextField的位置Y
    CGRect bookinfoframe=CGRectMake(bookinfoX, bookinfoY, 300, 30); //书名 长宽高
    self.BookInfoText.frame=bookinfoframe;
    self.BookInfoText.backgroundColor=[UIColor whiteColor];
    self.BookInfoText.layer.cornerRadius=5.0;
    self.BookInfoText.placeholder=@" 图书描述";
    
    [self.view addSubview:self.BookInfoText];  //加入view中
    
    
    
    //-----作者名称TEXTFIELD
    self.AuthorNameText=[[UITextField alloc]init];
    CGFloat authorNX=bookX;   //作者label的位置X
    CGFloat authorNY=bookinfoY+delta;
    CGRect authorframe=CGRectMake(authorNX , authorNY, 100, 30); //作者 长宽高
    self.AuthorNameText.frame=authorframe;
    self.AuthorNameText.backgroundColor=[UIColor whiteColor];
    self.AuthorNameText.layer.cornerRadius=5.0;
    self.AuthorNameText.placeholder=@"  作者姓名";
    
    [self.view addSubview:self.AuthorNameText];  //加入view中
    
    
    //-----出版社TEXTFIELD
    self.PublisherText=[[UITextField alloc]init];
    CGFloat pubX=bookX+120;   //出版社Textfield的位置X
    CGFloat pubY=authorNY;   //出版社Textfield的位置Y
    CGRect pubframe=CGRectMake(pubX , pubY, 180, 30); //出版社 长宽高
    self.PublisherText.frame=pubframe;
    self.PublisherText.backgroundColor=[UIColor whiteColor];
    self.PublisherText.layer.cornerRadius=5.0;
    self.PublisherText.placeholder=@"  出版社";
    [self.view addSubview:self.PublisherText];  //加入view中
    
#pragma mark-添加合法性验证
    //-----作者手机TEXTFIELD
    self.AuthorNumText=[[UITextField alloc]init];
    CGFloat authorNumX=bookX;   //作者电话号码TEXTFIELD的位置X
    CGFloat authorNumY=authorNY+delta;   //作者电话号码TEXTFIELD的位置Y
    CGRect authorNumframe=CGRectMake(authorNumX , authorNumY, 300, 30); //作者电话号码 长宽高
    self.AuthorNumText.backgroundColor=[UIColor whiteColor];
    self.AuthorNumText.layer.cornerRadius=5.0;
    self.AuthorNumText.placeholder=@"  作者手机";
    
    self.AuthorNumText.frame=authorNumframe;
    
    [self.view addSubview:self.AuthorNumText];  //加入view中
    
#pragma mark-添加合法性验证
    //-----作者邮箱TEXTFIELD
    self.AuhorMailText=[[UITextField alloc]init];
    CGFloat authorMailX=bookX;   //作者邮箱label的位置X
    CGFloat authorMailY=authorNumY+delta;   //作者邮箱label的位置Y
    CGRect authorMailframe=CGRectMake(authorMailX , authorMailY, 300, 30); //作者邮箱 长宽高
    self.AuhorMailText.frame=authorMailframe;
    self.AuhorMailText.backgroundColor=[UIColor whiteColor];
    self.AuhorMailText.layer.cornerRadius=5.0;
    self.AuhorMailText.placeholder=@"  作者邮箱";
    
    [self.view addSubview:self.AuhorMailText];  //加入view中
    
#pragma mark-添加时间控件
    //-----出版时间TEXTFIELD
    self.PublisherDateText =[[UITextField alloc]init];
    CGFloat pubDateX=bookX;   //出版时间的位置X
    CGFloat pubDateY=authorMailY+delta;   //出版时间的位置Y
    CGRect pubDateframe=CGRectMake(pubDateX , pubDateY, 300, 30); //出版时间 长宽高
    self.PublisherDateText.frame=pubDateframe;
    self.PublisherDateText.backgroundColor=[UIColor whiteColor];
    self.PublisherDateText.layer.cornerRadius=5.0;
    self.PublisherDateText.placeholder=@"  出版时间";
    
    [self.view addSubview:self.PublisherDateText];  //加入view中
    
    
    
    
    //上传按钮
    self.UploadBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat UploadBtnX=bookX;   //上传按钮的位置X
    CGFloat UploadBtnY=pubDateY+120;   //上传按钮的位置Y
    CGRect UploadBtnframe=CGRectMake(UploadBtnX , UploadBtnY, 300, 50); //上传按钮 长宽高
    self.UploadBtn.frame=UploadBtnframe;
    self.UploadBtn.backgroundColor=[UIColor whiteColor];
    self.UploadBtn.layer.cornerRadius=10.0;
    
    [self.UploadBtn setTitle:@"确 认" forState:UIControlStateNormal];
    self.UploadBtn.titleLabel.font=[UIFont boldSystemFontOfSize:20.0];
    self.UploadBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.UploadBtn setTitleColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1] forState:UIControlStateNormal];
    
    [self.view addSubview:self.UploadBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
