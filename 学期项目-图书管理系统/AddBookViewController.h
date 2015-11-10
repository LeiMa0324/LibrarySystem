//
//  AddBookViewController.h
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBookViewController : UIViewController

@property (nonatomic,strong) UIImageView *BookPicView;
@property (nonatomic,strong) UITextField *BooknameText;    //图书名称TEXTFIELD
@property (nonatomic,strong) UITextField *BookInfoText;    //图书描述TEXTFIELD
@property (nonatomic,strong) UITextField *AuthorNameText;  //作者名称TEXTFIELD
@property (nonatomic,strong) UITextField *PublisherText;   //出版社TEXTFIELD
@property (nonatomic,strong) UITextField *AuthorNumText;   //作者手机TEXTFIELD
@property (nonatomic,strong) UITextField *AuhorMailText;   //作者邮箱TEXTFIELD
@property (nonatomic,strong) UITextField *PublisherDateText;   //出版时间TEXTFIELD



@property (nonatomic,strong) UIButton *PhotoBtn;    //拍照按钮
@property (nonatomic,strong) UILabel *desc;
@property (nonatomic,strong) UIButton *UploadBtn;   //上传按钮



@end
