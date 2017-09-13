//
//  ViewController.m
//  XXPageTabDemo
//
//  Created by HJTXX on 2017/2/23.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import "ViewController.h"
#import "XXPageTabView.h"
#import "XXPageTabItemLable.h"
#import "TestTableViewController.h"

@interface ViewController () <XXPageTabViewDelegate>

@property (nonatomic, strong) XXPageTabView *pageTabView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *test1 = [self makeVC];
    UIViewController *test2 = [self makeVC];
    UIViewController *test3 = [self makeVC];
    UIViewController *test4 = [self makeVC];
    UIViewController *test5 = [self makeVC];
    UIViewController *test6 = [self makeVC];
    UIViewController *test7 = [self makeVC];
    UIViewController *test8 = [self makeVC];
    UIViewController *test9 = [self makeVC];
    UIViewController *test10 = [self makeVC];
    
    [self addChildViewController:test1];
    [self addChildViewController:test2];
    [self addChildViewController:test3];
    [self addChildViewController:test4];
    [self addChildViewController:test5];
    [self addChildViewController:test6];
    [self addChildViewController:test7];
    [self addChildViewController:test8];
    [self addChildViewController:test9];
    [self addChildViewController:test10];
    
    //支持网易云音乐，今日头条，微博等切换栏效果
    self.pageTabView = [[XXPageTabView alloc] initWithChildControllers:self.childViewControllers childTitles:@[@"列表1", @"列表2", @"列表3", @"列表4", @"列表5", @"列表6", @"列表7", @"列表8", @"列表9", @"列表10"]];
    self.pageTabView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    self.pageTabView.delegate = self;
//    self.pageTabView.bodyEnableScroll = NO;
//    self.pageTabView.bodyBounces = NO;
//    self.pageTabView.tabSize = CGSizeMake(self.view.frame.size.width, 40);
    self.pageTabView.titleStyle = XXPageTabTitleStyleDefault;
    self.pageTabView.indicatorStyle = XXPageTabIndicatorStyleDefault;
//    self.pageTabView.separatorColor = [UIColor grayColor];
//    self.pageTabView.minScale = 1.0;
    self.pageTabView.selectedTabIndex = 4;
//    self.pageTabView.selectedTabIndex = -1;
//    self.pageTabView.selectedTabIndex = 4;
    
//    self.pageTabView.maxNumberOfPageItems = 1;
//    self.pageTabView.maxNumberOfPageItems = 7;
    
//    self.pageTabView.tabItemFont = [UIFont systemFontOfSize:18];
    
//    self.pageTabView.indicatorHeight = 5;
    self.pageTabView.indicatorWidth = 20;
//    self.pageTabView.tabBackgroundColor = [UIColor yellowColor];
//    self.pageTabView.unSelectedColor = [UIColor greenColor];
    
//    self.pageTabView.tabSize = CGSizeMake(self.view.bounds.size.width-30, 0);
    [self.view addSubview:self.pageTabView];
    
    //左右切换按钮
    UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 30)];
    lastBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [lastBtn setTitle:@"上一页" forState:UIControlStateNormal];
    [lastBtn addTarget:self action:@selector(scrollToLast:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lastBtn];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 20, 60, 30)];
    nextBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [nextBtn setTitle:@"下一页" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(scrollToNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    //修改按钮
    UIButton *refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 20, 60, 30)];
    refreshBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [refreshBtn setTitle:@"自定义" forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshPageTabView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBtn];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (UIViewController *)makeVC {
    TestTableViewController *vc = [TestTableViewController new];
    return vc;
}

#pragma mark - XXPageTabViewDelegate
- (void)pageTabViewDidEndChange {
    NSLog(@"#####%d", (int)self.pageTabView.selectedTabIndex);
}

#pragma mark - Event response 
- (void)scrollToLast:(id)sender {
    [self.pageTabView setSelectedTabIndexWithAnimation:self.pageTabView.selectedTabIndex-1];
}

- (void)scrollToNext:(id)sender {
    [self.pageTabView setSelectedTabIndexWithAnimation:self.pageTabView.selectedTabIndex+1];
}

- (void)refreshPageTabView:(id)sender {
    //移除原有子控制器
    for(UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
    
    UIViewController *test1 = [self makeVC];
    UIViewController *test2 = [self makeVC];
    UIViewController *test3 = [self makeVC];
    UIViewController *test4 = [self makeVC];
    UIViewController *test5 = [self makeVC];
    
    [self addChildViewController:test1];
    [self addChildViewController:test2];
    [self addChildViewController:test3];
    [self addChildViewController:test4];
    [self addChildViewController:test5];
    
    [self.pageTabView reloadChildControllers:self.childViewControllers childTitles:@[@"列表1", @"列表2", @"列表3", @"列表4", @"列表5"]];
}

@end
