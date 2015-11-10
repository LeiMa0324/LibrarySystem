//
//  AccountViewController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/10.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountTableViewCell.h"

@interface AccountViewController ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.tableView.dataSource=self;     //指派委托
    self.tableView.delegate=self;       //指派委托
    
    [self.view addSubview:self.tableView];
}

//1.@required
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger i;
    i=(section==0)?1:10;
    return i;
}



//2.@required 初始化cell
-(AccountTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    AccountTableViewCell *cell=[[AccountTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (indexPath.section==0) {
        cell.textLabel.text=@"修改账户";    //section0的cell显示修改账户信息
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;   //增加箭头
    }
    else
    {
        for (int i=0; i<=indexPath.row; i++) {
            cell.textLabel.text=[NSString stringWithFormat: @"2015-10-%02d",i];
        }
    }
    
    
    return cell;
}


//3.optional 编辑section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

//4.optional 编辑sectionhead
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"帐号管理";
    }
    else
        return @"最近登录";
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
