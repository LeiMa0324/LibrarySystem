//
//  UserGuideController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "UserGuideController.h"

//获取屏幕frame，宽度、高度
#define SCREEN_FRAME ([UIScreen mainScreen].bounds)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface UserGuideController ()

@end

@implementation UserGuideController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    //初始化scrollview
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsVerticalScrollIndicator = NO;   //隐藏左右引导条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;     //确认控件是否整页滚动 YES
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2,scrollView.frame.size.height);
    scrollView.delegate = self; //设置代理
    
    //初始化5个imageView
    
    m_pImageView1 = [[UIImageView alloc] initWithFrame:frame];  //image为整屏
//    m_pImageView1.image = [UIImage imageNamed:@"Image1"];   //image1的图片
    m_pImageView1.backgroundColor=[UIColor whiteColor];
    
    m_pImageView2 = [[UIImageView alloc] initWithFrame:frame];
    m_pImageView2.frame = CGRectMake(frame.size.width,0, frame.size.width, frame.size.height);
//    m_pImageView2.image = [UIImage imageNamed:@"Image2"];
    m_pImageView2.backgroundColor=[UIColor greenColor];
    
    m_pImageView3 = [[UIImageView alloc] initWithFrame:frame];
    m_pImageView3.frame = CGRectMake(frame.size.width,0, frame.size.width, frame.size.height);
//    m_pImageView3.image = [UIImage imageNamed:@"Image3"];
    m_pImageView3.backgroundColor=[UIColor blueColor];
    
    m_pImageView4 = [[UIImageView alloc] initWithFrame:frame];
    m_pImageView4.frame = CGRectMake(frame.size.width,0, frame.size.width, frame.size.height);
    m_pImageView4.backgroundColor=[UIColor blackColor];
//    m_pImageVie4.image = [UIImage imageNamed:@"Image4"];
    
    m_pImageView5 = [[UIImageView alloc] initWithFrame:frame];
    m_pImageView5.frame = CGRectMake(frame.size.width,0, frame.size.width, frame.size.height);
//    m_pImageView5.image = [UIImage imageNamed:@"Image5"];
    m_pImageView4.backgroundColor=[UIColor redColor];
    
    //初始化pageControl，下面的小点点
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((frame.size.width-100)/2, frame.size.height-40, 100, 20)];
    
    pageControl.numberOfPages = 5;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    
    [scrollView addSubview:m_pImageView1];
    [scrollView addSubview:m_pImageView2];
    [scrollView addSubview:m_pImageView3];
    [scrollView addSubview:m_pImageView4];
    [scrollView addSubview:m_pImageView5];
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];

    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControl)
    {
        return;
    }
    CGFloat pageWidth = self->scrollView.frame.size.width;  //
    int page = floor((self->scrollView.contentOffset.x - pageWidth / 2)/pageWidth)+1;
    pageControl.currentPage = page;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    pageControlUsed = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageControlUsed = NO;
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
