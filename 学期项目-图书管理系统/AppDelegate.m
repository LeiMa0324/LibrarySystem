//
//  AppDelegate.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/9.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "IQKeyboardManager.h"
#import "AddBookViewController.h"
#import "EditBookViewController.h"
#import "AccountViewController.h"
#import "ChangeAccountViewController.h"
#import "SignInViewController.h"
#import "UserGuideController.h"


#define KeyBoardManager [IQKeyboardManager sharedManager]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds] ];
    
//    //判断应用程序是否是第一次启动,如果是,则展示用户引导界面,如果不是,则直接进入主界面
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        
        NSLog(@"第一次启动");
        
        //第一次执行进入用户引导界面(self.window根视图指定为引导界面的控制器)
        
        //UserGuideController实例化
        UserGuideController *userGuideController=[[UserGuideController alloc]init];
        
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:userGuideController];
        
        //将UINavigationController对象设置为UIWindow对象的根视图控制器
        //这样就可以将UINavigationController的对象的视图添加到屏幕上
        self.window.rootViewController=navController;
    
    } else {
    
        NSLog(@"不是第一次启动");
        //mainViewController实例化
        ViewController *itemsViewController=[[ViewController alloc]init];
        
        //LoginViewController实例化
        LoginViewController *loginViewController=[[LoginViewController alloc]init];
        
        //AddBookViewController实例化
        AddBookViewController *addViewController=[[AddBookViewController alloc]init];
        
        //editBookViewController实例化
        EditBookViewController *editBookViewController=[[EditBookViewController alloc]init];
        
        //AccountViewController实例化
        AccountViewController *accountViewController=[[AccountViewController alloc]init];
        
        //ChangeAccountViewController实例化
        ChangeAccountViewController *changeAccountViewController=[[ChangeAccountViewController alloc]init];
        
        //SignInViewController实例化
        SignInViewController *signInViewController=[[SignInViewController alloc]init];
    
        //不是第一次进入,则(self.window根视图指定为主界面界面的控制器)
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:itemsViewController];
        //将UINavigationController对象设置为UIWindow对象的根视图控制器
        //这样就可以将UINavigationController的对象的视图添加到屏幕上
        self.window.rootViewController=navController;
    
    }
    
    
    
    
    
    
   
    
    //创建UINavigationController对象，该对象的栈只包括itemsViewController
 
//    navController.navigationBarHidden=YES;
    
    
    [self.window makeKeyAndVisible];
    [KeyBoardManager setEnable:YES];
    [KeyBoardManager setEnableAutoToolbar:NO];
    [KeyBoardManager setKeyboardDistanceFromTextField:15];
    [KeyBoardManager setShouldResignOnTouchOutside:YES];
    [KeyBoardManager setToolbarManageBehaviour:IQAutoToolbarBySubviews];
    [KeyBoardManager setCanAdjustTextView:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
