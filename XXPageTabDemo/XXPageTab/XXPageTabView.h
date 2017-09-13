//
//  XXPageTabView.h
//  XXPageTabDemo
//
//  Created by HJTXX on 2017/2/27.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XXPageTabTitleStyle) {
    XXPageTabTitleStyleDefault, //正常
    XXPageTabTitleStyleGradient, //渐变
    XXPageTabTitleStyleBlend //填充
};

typedef NS_ENUM(NSInteger, XXPageTabIndicatorStyle) {
    XXPageTabIndicatorStyleDefault, //正常，自定义宽度
    XXPageTabIndicatorStyleFollowText, //跟随文本长度变化
    XXPageTabIndicatorStyleStretch //拉伸
};

@protocol XXPageTabViewDelegate <NSObject>
/*切换完成代理方法*/
- (void)pageTabViewDidEndChange;
@end

@interface XXPageTabView : UIView

@property (nonatomic, weak) id<XXPageTabViewDelegate> delegate;

/*设置当前选择项（无动画效果）*/
@property (nonatomic, assign) NSInteger selectedTabIndex;
/*一页展示最多的item个数，如果比item总数少，按照item总数计算*/
@property (nonatomic, assign) NSInteger maxNumberOfPageItems;
/*tab size，默认(self.width, 38.0)*/
@property (nonatomic, assign) CGSize tabSize;
/*item的字体大小*/
@property (nonatomic, strong) UIFont *tabItemFont;
/*未选择颜色*/
@property (nonatomic, strong) UIColor *unSelectedColor;
/*当前选中颜色*/
@property (nonatomic, strong) UIColor *selectedColor;
/*tab背景色，默认white*/
@property (nonatomic, strong) UIColor *tabBackgroundColor;
/*body背景色，默认white*/
@property (nonatomic, strong) UIColor *bodyBackgroundColor;
/*底部分割线颜色，默认clear*/
@property (nonatomic, strong) UIColor *separatorColor;
/*是否打开body的边界弹动效果，默认YES*/
@property (nonatomic, assign) BOOL bodyBounces;
/*是否允许body滚动，默认YES*/
@property (nonatomic, assign) BOOL bodyScrollEnabled;

/*Title效果设置*/
@property (nonatomic, assign) XXPageTabTitleStyle titleStyle;
/*字体渐变，未选择的item的scale，默认是0.8（0~1）。仅XXPageTabTitleStyleScale生效*/
@property (nonatomic, assign) CGFloat minScale;

/*Indicator效果设置*/
@property (nonatomic, assign) XXPageTabIndicatorStyle indicatorStyle;
/*下标高度，默认是2.0*/
@property (nonatomic, assign) CGFloat indicatorHeight;
/*下标宽度，默认是0。XXPageTabIndicatorStyleFollowText时无效*/
@property (nonatomic, assign) CGFloat indicatorWidth;

- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)childControllers
                             childTitles:(NSArray<NSString *> *)childTitles;

/*重新加载内容（可用于菜单栏自定义编辑）*/
- (void)reloadChildControllers:(NSArray<UIViewController *> *)childControllers
                   childTitles:(NSArray<NSString *> *)childTitles;

/*用于外部设置selectedTabIndex时动画展示*/
- (void)setSelectedTabIndexWithAnimation:(NSInteger)selectedTabIndex;

@end
