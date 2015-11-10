//
//  UserGuideController.h
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserGuideController : UIViewController<UIScrollViewDelegate>

{
    UIScrollView *scrollView;
    
    UIImageView *m_pImageView1;
    
    UIImageView *m_pImageView2;
    
    UIImageView *m_pImageView3;
    
    UIImageView *m_pImageView4;
    
    UIImageView *m_pImageView5;
    
    UIPageControl *pageControl;
    
    BOOL pageControlUsed;
}

@end
