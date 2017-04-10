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

@interface ViewController () <XXPageTabViewDelegate>

@property (nonatomic, strong) XXPageTabView *pageTabView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *test1 = [self makeVCWthColor:[UIColor colorWithRed:0.996 green:0.616 blue:0.004 alpha:1.00]];
    UIViewController *test2 = [self makeVCWthColor:[UIColor colorWithRed:0.024 green:0.373 blue:0.725 alpha:1.00]];
    UIViewController *test3 = [self makeVCWthColor:[UIColor colorWithRed:0.298 green:0.298 blue:0.298 alpha:1.00]];
    UIViewController *test4 = [self makeVCWthColor:[UIColor colorWithRed:0.439 green:0.882 blue:1.000 alpha:1.00]];
    UIViewController *test5 = [self makeVCWthColor:[UIColor colorWithRed:0.902 green:0.910 blue:0.922 alpha:1.00]];
    
    [self addChildViewController:test1];
    [self addChildViewController:test2];
    [self addChildViewController:test3];
    [self addChildViewController:test4];
    [self addChildViewController:test5];
    
    //支持网易云音乐，今日头条，微博等切换栏效果
    self.pageTabView = [[XXPageTabView alloc] initWithChildControllers:self.childViewControllers childTitles:@[@"新浪",@"百度",@"搜狐视频",@"腾讯",@"网易"]];
    self.pageTabView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    self.pageTabView.delegate = self;
//    self.pageTabView.bodyBounces = NO;
//    self.pageTabView.tabSize = CGSizeMake(self.view.frame.size.width, 40);
    self.pageTabView.titleStyle = XXPageTabTitleStyleDefault;
    self.pageTabView.indicatorStyle = XXPageTabIndicatorStyleDefault;
//    self.pageTabView.minScale = 1.0;
//    self.pageTabView.selectedTabIndex = 4;
//    self.pageTabView.selectedTabIndex = -1;
//    self.pageTabView.selectedTabIndex = 7;
    
//    self.pageTabView.maxNumberOfPageItems = 1;
//    self.pageTabView.maxNumberOfPageItems = 7;
    
//    self.pageTabView.tabItemFont = [UIFont systemFontOfSize:18];
    
//    self.pageTabView.indicatorHeight = 5;
    self.pageTabView.indicatorWidth = 20;
//    self.pageTabView.tabBackgroundColor = [UIColor yellowColor];
//    self.pageTabView.unSelectedColor = [UIColor greenColor];
    
//    self.pageTabView.tabSize = CGSizeMake(self.view.bounds.size.width-30, 0);
    [self.view addSubview:self.pageTabView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)pageTabViewDidEndChange {
//    if(self.pageTabView.selectedTabIndex == 2) {
//        self.pageTabView.frame = CGRectMake(0, 60, self.view.frame.size.width, 200);
//    } else {
//        self.pageTabView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
//    }
    NSLog(@"#####%d", self.pageTabView.selectedTabIndex);
}

- (UIViewController *)makeVCWthColor:(UIColor *)color {
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = color;
    return vc;
}

@end
