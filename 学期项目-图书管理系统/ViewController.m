//
//  ViewController.m
//  学期项目-图书管理系统
//
//  Created by APPLE on 15/11/9.
//  Copyright (c) 2015年 big nerd ranch. All rights reserved.
//

#import "ViewController.h"
#import "BookInfo.h"
#import "TableViewCell.h"
#import "LoginViewController.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>


@property (strong, nonatomic)  UITableView *tableView;
@property (strong,nonatomic)  UITextField *searchBar;   //搜索框
@property (strong,nonatomic)  UIButton *headBtn;
@property (strong,nonatomic)   UIView *m_pview;
@property (strong,nonatomic) UIButton *AddBook; //添加图书按钮



//@property(nonatomic,strong) NSMutableArray *dataList;   //用于存放BookInfo对象的动态数组


@end

@implementation ViewController

//tableView的显示

//1.@required 设置section中的个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        NSLog(@"%s",__func__);
    if(section==0)
        return 5;
    else
        return 18;
}

//2.@required 初始化cell
-(TableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSLog(@"%s",__func__);
    TableViewCell *cell=[[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    

//    cell.textLabel.text= [NSString stringWithFormat:@"图书项目%02d-%04d",indexPath.section,indexPath.row];
    
    cell.BooknameLabel.text=@"人生简史";
    cell.AuthorNameLabel.text=@"作者：马蕾";
    cell.PublisherLabel.text=@"408出版社";
    cell.AuthorNumLabel.text=@"手机：186264569915";
    cell.AuhorMailLabel.text=@"邮箱：gorillazhip@126.com";
    cell.PublisherDateLabel.text=@"出版时间：2015-10-01";
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;   //创建箭头
  
    return cell;
}


//3.optional返回分组的标题文字
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSLog(@"返回分组的标题文字");
    return [NSString stringWithFormat:@"图书列表%02d",section];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    LoginViewController*view = [[LoginViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
}

//4.optional section的个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//
////5、optional 改变cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
        return 80;
}

//6、optional 改变head的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 30;
}
//7、滑动cell删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableVieweditingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//当在Cell上滑动时会调用此函数

{
    NSLog(@"删除单元格");
        
        return  UITableViewCellEditingStyleDelete;  //显示删除键
    
}


//数据删除操作
- (void) tableView:(UITableView *)tableViewcommitEditingStyle:(UITableViewCellEditingStyle)editingStyleforRowAtIndexPath:(NSIndexPath *)indexPath 　　//对选中的Cell根据editingStyle进行操作

{
    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//        
//    {
//        
//        if (temp == 1)　　//将单元格从数据库1中删除
//            
//        {
//            
//            [[CommonDatainstance] delEntity:[[[CommonDatainstance] gainSelectResult] objectAtIndexPath:indexPath]];
//            
//            [[CommonDatainstance] saveDB];
//            
//            [[CommonDatainstance] refreshResult:[[CommonDatainstance] gainSelectResult]];
//            
//            NSArray *array = [[CommonDatainstance] gainSelectResult].fetchedObjects;
//            
//            array =  [[self changeArrayForm:array] copy];
//            
//            self.listData = array;
//            
//            [myTableView reloadData];
//            
//        }
//        
//        else if (temp == 2) ////将单元格从数据库2中删除
//            
//        {
//            
//            [[CommonDatainstance] delEntity:[[[CommonDatainstance] gainRecentResult] objectAtIndexPath:indexPath]];
//            
//            [[CommonDatainstance] saveDB];
//            
//            [[CommonDatainstance] refreshResult:[[CommonDatainstance] gainRecentResult]];
//            
//            NSArray *array = [[CommonDatainstance] gainRecentResult].fetchedObjects;
//            
//            array =  [[self changeArrayForm:array] copy];
//            
//            self.listData = array;
//            
//            [myTableView reloadData];
//            
//        }
//        
//    }
    
}




//8、optional 删除时显示提示信息
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"请确认删除";
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    //创建tableview的frame
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height-120)];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];      //指定委托
    
//    
    //创建搜索框
      self.searchBar=[[UITextField alloc] initWithFrame:CGRectMake(60,25, [UIScreen mainScreen].bounds.size.width-70, 30)];
     self.searchBar.backgroundColor=[UIColor whiteColor];
     self.searchBar.placeholder=[NSString stringWithFormat:@"搜索"];
    self.searchBar.textAlignment=NSTextAlignmentCenter;
    self.searchBar.layer.cornerRadius=10.0;


    //创建头像button
    self.headBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.headBtn setFrame:CGRectMake(10, 20, 40, 40) ];
    [self.headBtn setBackgroundImage:[UIImage imageNamed:@"head"] forState:UIControlStateNormal];//设置正常状态下的背景图片
    self.headBtn.layer.cornerRadius=20.0;
    self.headBtn.autoresizesSubviews = YES; //其子视图会根据autoresizing
    self.headBtn.layer.masksToBounds=YES;   //Mask属性的值自动进行尺寸调整（button中的imageView)

    
    //创建头部view
    self.m_pview =  [[UIView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 120)];
    self.m_pview.backgroundColor = [UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1];
    [self.m_pview addSubview:self.headBtn];
    [self.m_pview addSubview:self.searchBar];

    [self.view addSubview:self.tableView];
    [self.view addSubview :self.m_pview];
    
    
    //创建添加图书按钮
    self.AddBook =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.AddBook setFrame:CGRectMake(20, 80, [UIScreen mainScreen].bounds.size.width-40, 30) ];
    self.AddBook.backgroundColor=[UIColor whiteColor];

    self.AddBook.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
    self.AddBook.titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.AddBook setTitleColor:[UIColor colorWithRed:0x9f/255.0 green:0xcb/255.0 blue:0xcc/255.0  alpha:1] forState:UIControlStateNormal];
    [self.AddBook setTitle:@"+添加图书" forState:UIControlStateNormal];
    
    self.AddBook.layer.cornerRadius=10.0;
    
    
    [self.m_pview addSubview:self.AddBook];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
