//
//  XXPageTabView.m
//  XXPageTabDemo
//
//  Created by HJTXX on 2017/2/27.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import "XXPageTabView.h"
#import "XXPageTabItemLable.h"

#define kTabDefautHeight 38.0
#define kTabDefautFontSize 15.0
#define kMaxNumberOfPageItems 4
#define kIndicatorHeight 2.0
#define kIndicatorWidth 20
#define kMinScale 0.8

#define HEIGHT(view) view.bounds.size.height
#define WIDTH(view) view.bounds.size.width
#define ORIGIN_X(view) view.frame.origin.x
#define ORIGIN_Y(view) view.frame.origin.y

@interface XXPageTabView () <UIScrollViewDelegate>
//bg
@property (nonatomic, strong) UIView *bgView; //由于遇到nav->vc，vc的第一个子试图是UIScrollView会自动产生64像素偏移，所以加上一个虚拟背景（没有尺寸）

//tab
@property (nonatomic, strong) UIScrollView *tabView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIView *separatorView;

//body
@property (nonatomic, strong) UIScrollView *bodyView;

//data
@property (nonatomic, assign) NSInteger lastSelectedTabIndex; //记录上一次的索引
@property (nonatomic, assign) NSInteger numberOfTabItems;
@property (nonatomic, assign) CGFloat tabItemWidth;
@property (nonatomic, strong) NSMutableArray *tabItems;
@property (nonatomic, strong) NSArray *childControllers;
@property (nonatomic, strong) NSArray *childTitles;

//animation
@property (nonatomic, assign) BOOL isNeedRefreshLayout; //滑动过程中不允许layoutSubviews
@property (nonatomic, assign) BOOL isChangeByClick; //是否是通过点击改变的。因为点击可以长距离点击，部分效果不作处理会出现途中经过的按钮也会依次有效果（仿网易客户端有此效果，个人觉得并不好，头条的客户端更合理）
@property (nonatomic, assign) NSInteger leftItemIndex; //记录滑动时左边的itemIndex
@property (nonatomic, assign) NSInteger rightItemIndex; //记录滑动时右边的itemIndex

/*XXPageTabTitleStyleScale*/
@property (nonatomic, assign) CGFloat selectedColorR;
@property (nonatomic, assign) CGFloat selectedColorG;
@property (nonatomic, assign) CGFloat selectedColorB;
@property (nonatomic, assign) CGFloat unSelectedColorR;
@property (nonatomic, assign) CGFloat unSelectedColorG;
@property (nonatomic, assign) CGFloat unSelectedColorB;

@end

@implementation XXPageTabView

#pragma mark - Life cycle
- (instancetype)initWithChildControllers:(NSArray<UIViewController *> *)childControllers
                             childTitles:(NSArray<NSString *> *)childTitles {
    self = [super init];
    if(self) {
        _childControllers = childControllers;
        _childTitles = childTitles;
        
        [self initBaseSettings];
        [self initTabView];
        [self initMainView];
        [self addIndicatorViewWithStyle];
    }
    return self;
}

- (void)reloadChildControllers:(NSArray<UIViewController *> *)childControllers
                   childTitles:(NSArray<NSString *> *)childTitles {
    if(childControllers.count>0 && childTitles.count>0) {
        //记录上一次选择项的标题
        NSString *selectedChildTitle = _childTitles[_selectedTabIndex];
        _selectedTabIndex = 0;//更新索引，默认0
        for(NSString *childTitle in childTitles) {
            if([childTitle isEqualToString:selectedChildTitle]) {
                _selectedTabIndex = [childTitles indexOfObject:childTitle];
            }
        }
        
        //更新部分数据
        _childControllers = childControllers;
        _childTitles = childTitles;
        _numberOfTabItems = _childControllers.count>_childTitles.count?_childTitles.count:_childControllers.count;
        _lastSelectedTabIndex = 0;
        _leftItemIndex = 0;
        _rightItemIndex = 0;
        
        //更新内容
        [self resetTabView];
        [self resetMainView];
        
        //刷新布局
        _isNeedRefreshLayout = YES;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    if(_isNeedRefreshLayout) {
        //tab layout
        if(_tabSize.height <= 0) {
            _tabSize.height = kTabDefautHeight;
        }
        if(_tabSize.width <= 0) {
            _tabSize.width = WIDTH(self);
        }
        _tabItemWidth = _tabSize.width/(_numberOfTabItems<_maxNumberOfPageItems?_numberOfTabItems:_maxNumberOfPageItems);
        
        self.tabView.frame = CGRectMake(0, 0, _tabSize.width, _tabSize.height);
        self.tabView.contentSize = CGSizeMake(_tabItemWidth*_numberOfTabItems, 0);
        self.separatorView.frame = CGRectMake(0, _tabSize.height-0.5, _tabSize.width, 0.5);
        
        for(NSInteger i = 0; i < _tabItems.count; i++) {
            XXPageTabItemLable *tabItem = (XXPageTabItemLable *)_tabItems[i];
            tabItem.frame = CGRectMake(_tabItemWidth*i, 0, _tabItemWidth, _tabSize.height);
        }
        [self layoutIndicatorViewWithStyle];

        //body layout
        self.bodyView.frame = CGRectMake(0, _tabSize.height, WIDTH(self), HEIGHT(self)-_tabSize.height);
        self.bodyView.contentOffset = CGPointMake(self.frame.size.width*_selectedTabIndex, 0);
        self.bodyView.contentSize = CGSizeMake(WIDTH(self)*_numberOfTabItems, 0);
        [self reviseTabContentOffsetBySelectedIndex:NO];
        
        for(NSInteger i = 0; i < _numberOfTabItems; i++) {
            UIViewController *childController = _childControllers[i];
            childController.view.frame = CGRectMake(WIDTH(self)*i, 0, WIDTH(self), HEIGHT(self)-_tabSize.height);
        }
    }
}

#pragma mark - Layout
- (void)initBaseSettings {
    _selectedTabIndex = 0;
    _lastSelectedTabIndex = 0;
    _leftItemIndex = 0;
    _rightItemIndex = 0;
    _tabSize = CGSizeZero;
    _numberOfTabItems = _childControllers.count>_childTitles.count?_childTitles.count:_childControllers.count;
    _tabItemFont = [UIFont systemFontOfSize:kTabDefautFontSize];
    _indicatorHeight = kIndicatorHeight;
    _indicatorWidth = kIndicatorWidth;
    _maxNumberOfPageItems = kMaxNumberOfPageItems;
    _tabItems = [NSMutableArray array];
    _tabBackgroundColor = [UIColor whiteColor];
    _bodyBackgroundColor = [UIColor whiteColor];
    _unSelectedColor = [UIColor blackColor];
    _selectedColor = [UIColor redColor];
    _separatorColor = [UIColor clearColor];
    _isNeedRefreshLayout = YES;
    _isChangeByClick = NO;
    _bodyBounces = YES;
    _bodyScrollEnabled = YES;
    _titleStyle = XXPageTabTitleStyleDefault;
    _indicatorStyle = XXPageTabIndicatorStyleDefault;
    _minScale = kMinScale;
    _selectedColorR = 1;
    _selectedColorG = 0;
    _selectedColorB = 0;
    _unSelectedColorR = 0;
    _unSelectedColorG = 0;
    _unSelectedColorB = 0;
}

- (void)initTabView {
    if(!self.bgView.superview) {
        [self addSubview:self.bgView];
    }
    
    if(!self.tabView.superview) {
        [self addSubview:self.tabView];
    }
    
    if(!self.separatorView.superview) {
        [self addSubview:self.separatorView];
    }
    
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        XXPageTabItemLable *tabItem = [[XXPageTabItemLable alloc] init];
        tabItem.font = _tabItemFont;
        tabItem.text = _childTitles[i];
        tabItem.textColor = i==_selectedTabIndex?_selectedColor:_unSelectedColor;
        tabItem.textAlignment = NSTextAlignmentCenter;
        tabItem.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeChildControllerOnClick:)];
        [tabItem addGestureRecognizer:tapRecognizer];
        [_tabItems addObject:tabItem];
        [self.tabView addSubview:tabItem];
    }
}

- (void)resetTabView {
    //清除已有内容
    for(UIView *view in self.tabItems) {
        [view removeFromSuperview];
    }
    [self.tabItems removeAllObjects];
    
    //重新加载
    [self initTabView];
}

- (void)initMainView {
    [self addSubview:self.bodyView];
    [self layoutChildViewWithIndex:_selectedTabIndex];
}

- (void)resetMainView {
    //清除已有内容
    for(UIView *view in self.bodyView.subviews) {
        [view removeFromSuperview];
    }
    
    //重新加载
    [self layoutChildViewWithIndex:_selectedTabIndex];
}

/**
 加载指定index的view

 @param index 需要展示的child的索引
 */
- (void)layoutChildViewWithIndex:(NSInteger)index {
    if(index >= 0 && index < _childControllers.count) {
        UIViewController *childController = _childControllers[index];
        if(childController.view.superview != self.bodyView) {
            [self.bodyView addSubview:childController.view];
        }
    }
}

/**
 根据选择项修正tab的展示区域
 */
- (void)reviseTabContentOffsetBySelectedIndex:(BOOL)isAnimate {
    XXPageTabItemLable *currentTabItem = _tabItems[_selectedTabIndex];
    CGFloat selectedItemCenterX = currentTabItem.center.x;
    
    CGFloat reviseX;
    if(selectedItemCenterX + _tabSize.width/2.0 >= self.tabView.contentSize.width) {
        reviseX = self.tabView.contentSize.width - _tabSize.width; //不足以到中心，靠右
    } else if(selectedItemCenterX - _tabSize.width/2.0 <= 0) {
        reviseX = 0; //不足以到中心，靠左
    } else {
        reviseX = selectedItemCenterX - _tabSize.width/2.0; //修正至中心
    }
    //如果前后没有偏移量差，setContentOffset实际不起作用；或者没有动画效果
    if(fabs(self.tabView.contentOffset.x - reviseX)<1 || !isAnimate) {
        [self finishReviseTabContentOffset];
    }
    [self.tabView setContentOffset:CGPointMake(reviseX, 0) animated:isAnimate];
}

/**
 tabview修正完成后的操作，无论是点击还是滑动body，此方法都是真正意义上的最后一步
 */
- (void)finishReviseTabContentOffset {
    _tabView.userInteractionEnabled = YES;
    _isNeedRefreshLayout = YES;
    _isChangeByClick = NO;
    if([self.delegate respondsToSelector:@selector(pageTabViewDidEndChange)]) {
        if(_lastSelectedTabIndex != _selectedTabIndex) {
            [self.delegate pageTabViewDidEndChange];
        }
    }
    _lastSelectedTabIndex = _selectedTabIndex;
}

/**
 一般常用改变selected Item方法(无动画效果，直接变色)
 */
- (void)changeSelectedItemToNextItem:(NSInteger)nextIndex {
    XXPageTabItemLable *currentTabItem = _tabItems[_selectedTabIndex];
    XXPageTabItemLable *nextTabItem = _tabItems[nextIndex];
    currentTabItem.textColor = _unSelectedColor;
    nextTabItem.textColor = _selectedColor;
}

#pragma mark -Title layout
/**
 重新设置item的缩放比例
 */
- (void)resetTabItemScale {
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        XXPageTabItemLable *tabItem = _tabItems[i];
        if(i != _selectedTabIndex) {
            tabItem.transform = CGAffineTransformMakeScale(_minScale, _minScale);
        } else {
            tabItem.transform = CGAffineTransformMakeScale(1, 1);
        }
    }
}

#pragma mark -Indicator layout
/**
 根据不同风格添加相应下标
 */
- (void)addIndicatorViewWithStyle {
    switch (_indicatorStyle) {
        case XXPageTabIndicatorStyleDefault:
        case XXPageTabIndicatorStyleFollowText:
        case XXPageTabIndicatorStyleStretch:
            [self addSubview:self.indicatorView];
            break;
        default:
            break;
    }
}

/**
 根据不同风格对下标layout
 */
- (void)layoutIndicatorViewWithStyle {
    switch (_indicatorStyle) {
        case XXPageTabIndicatorStyleDefault:
        case XXPageTabIndicatorStyleFollowText:
        case XXPageTabIndicatorStyleStretch:
            [self layoutIndicatorView];
            break;
        default:
            break;
    }
}

- (void)layoutIndicatorView {
    CGFloat indicatorWidth = [self getIndicatorWidthWithTitle:_childTitles[_selectedTabIndex]];
    XXPageTabItemLable *selecedTabItem = _tabItems[_selectedTabIndex];
    self.indicatorView.frame = CGRectMake(selecedTabItem.center.x-indicatorWidth/2.0-_tabView.contentOffset.x, _tabSize.height-_indicatorHeight, indicatorWidth, _indicatorHeight);
}

#pragma mark - Event response
- (void)changeChildControllerOnClick:(UITapGestureRecognizer *)tap {
    NSInteger nextIndex = [_tabItems indexOfObject:tap.view];
    if(nextIndex != _selectedTabIndex) {
        if(_titleStyle == XXPageTabTitleStyleDefault) {
            [self changeSelectedItemToNextItem:nextIndex];
        }
        
        _isChangeByClick = YES;
        _tabView.userInteractionEnabled = NO; //防止快速切换
        _leftItemIndex = nextIndex > _selectedTabIndex?_selectedTabIndex:nextIndex;
        _rightItemIndex = nextIndex > _selectedTabIndex?nextIndex:_selectedTabIndex;
        _selectedTabIndex = nextIndex;
        [self layoutChildViewWithIndex:_selectedTabIndex];
        [self.bodyView setContentOffset:CGPointMake(self.frame.size.width*_selectedTabIndex, 0) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
/*手指滑动会触发该方法，setContentOffset:animated:不会触发*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView == self.bodyView) {
        _selectedTabIndex = self.bodyView.contentOffset.x/WIDTH(self.bodyView);
        [self reviseTabContentOffsetBySelectedIndex:YES];
    }
}

/*setContentOffset:animated:会触发该方法，手指滑动不会触发*/
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if(scrollView == self.bodyView) {
        [self reviseTabContentOffsetBySelectedIndex:YES];
    } else {
        [self finishReviseTabContentOffset];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tabView) {
        _isNeedRefreshLayout = NO;
        if(self.indicatorView.superview) {
            XXPageTabItemLable *selecedTabItem = _tabItems[_selectedTabIndex];
            self.indicatorView.frame = CGRectMake(selecedTabItem.center.x-WIDTH(self.indicatorView)/2.0-scrollView.contentOffset.x, ORIGIN_Y(self.indicatorView), WIDTH(self.indicatorView), HEIGHT(self.indicatorView));
        }
    } else if(scrollView == self.bodyView) {
        //未初始化时不处理
        if(self.bodyView.contentSize.width <= 0) {
            return;
        }
        //滚动过程中不允许layout
        _isNeedRefreshLayout = NO;
        //获取当前左右item index(点击方式已获知左右index，无需根据contentoffset计算)
        if(!_isChangeByClick) {
            if(self.bodyView.contentOffset.x <= 0) { //左边界
                _leftItemIndex = 0;
                _rightItemIndex = 0;
                
            } else if(self.bodyView.contentOffset.x >= self.bodyView.contentSize.width-WIDTH(self.bodyView)) { //右边界
                _leftItemIndex = _numberOfTabItems-1;
                _rightItemIndex = _numberOfTabItems-1;
                
            } else {
                _leftItemIndex = (int)(self.bodyView.contentOffset.x/WIDTH(self.bodyView));
                _rightItemIndex = _leftItemIndex + 1;
            }
            //手势滚动过程中预加载左右页
            [self layoutChildViewWithIndex:_leftItemIndex];
            [self layoutChildViewWithIndex:_rightItemIndex];
        }
        
        //调整title
        switch (_titleStyle) {
            case XXPageTabTitleStyleDefault:
                [self changeTitleWithDefault];
                break;
            case XXPageTabTitleStyleGradient:
                [self changeTitleWithGradient];
                break;
            case XXPageTabTitleStyleBlend:
                [self changeTitleWithBlend];
                break;
            default:
                break;
        }
        
        //调整indicator
        switch (_indicatorStyle) {
            case XXPageTabIndicatorStyleDefault:
            case XXPageTabIndicatorStyleFollowText:
                [self changeIndicatorFrame];
                break;
            case XXPageTabIndicatorStyleStretch:
            {
                if(_isChangeByClick) {
                    [self changeIndicatorFrame];
                } else {
                    [self changeIndicatorFrameByStretch];
                }
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Title animation
- (void)changeTitleWithDefault {
    CGFloat relativeLocation = self.bodyView.contentOffset.x/WIDTH(self.bodyView)-_leftItemIndex;
    if(!_isChangeByClick) {
        if(relativeLocation > 0.5) {
            [self changeSelectedItemToNextItem:_rightItemIndex];
            _selectedTabIndex = _rightItemIndex;
        } else {
            [self changeSelectedItemToNextItem:_leftItemIndex];
            _selectedTabIndex = _leftItemIndex;
        }
    }
}

- (void)changeTitleWithGradient {
    if(_leftItemIndex != _rightItemIndex) {
        CGFloat rightScale = (self.bodyView.contentOffset.x/WIDTH(self.bodyView)-_leftItemIndex)/(_rightItemIndex-_leftItemIndex);
        CGFloat leftScale = 1-rightScale;
        
        //颜色渐变
        CGFloat difR = _selectedColorR-_unSelectedColorR;
        CGFloat difG = _selectedColorG-_unSelectedColorG;
        CGFloat difB = _selectedColorB-_unSelectedColorB;
        
        UIColor *leftItemColor = [UIColor colorWithRed:_unSelectedColorR+leftScale*difR green:_unSelectedColorG+leftScale*difG blue:_unSelectedColorB+leftScale*difB alpha:1];
        UIColor *rightItemColor = [UIColor colorWithRed:_unSelectedColorR+rightScale*difR green:_unSelectedColorG+rightScale*difG blue:_unSelectedColorB+rightScale*difB alpha:1];
        
        XXPageTabItemLable *leftTabItem = _tabItems[_leftItemIndex];
        XXPageTabItemLable *rightTabItem = _tabItems[_rightItemIndex];
        leftTabItem.textColor = leftItemColor;
        rightTabItem.textColor = rightItemColor;
        
        //字体渐变
        leftTabItem.transform = CGAffineTransformMakeScale(_minScale+(1-_minScale)*leftScale, _minScale+(1-_minScale)*leftScale);
        rightTabItem.transform = CGAffineTransformMakeScale(_minScale+(1-_minScale)*rightScale, _minScale+(1-_minScale)*rightScale);
    }
}

- (void)changeTitleWithBlend {
    CGFloat leftScale = self.bodyView.contentOffset.x/WIDTH(self.bodyView)-_leftItemIndex;
    if(leftScale == 0) {
        return; //起点和终点不处理，终点时左右index已更新，会绘画错误（你可以注释看看）
    }
    
    XXPageTabItemLable *leftTabItem = _tabItems[_leftItemIndex];
    XXPageTabItemLable *rightTabItem = _tabItems[_rightItemIndex];
    
    leftTabItem.textColor = _selectedColor;
    rightTabItem.textColor = _unSelectedColor;
    leftTabItem.fillColor = _unSelectedColor;
    rightTabItem.fillColor = _selectedColor;
    leftTabItem.process = leftScale;
    rightTabItem.process = leftScale;
}

#pragma mark - Indicator animation
- (void)changeIndicatorFrame {
    //计算indicator此时的centerx
    CGFloat nowIndicatorCenterX = _tabItemWidth*(0.5+self.bodyView.contentOffset.x/WIDTH(self.bodyView));
    //计算此时body的偏移量在一页中的占比
    CGFloat relativeLocation = (self.bodyView.contentOffset.x/WIDTH(self.bodyView)-_leftItemIndex)/(_rightItemIndex-_leftItemIndex);
    //记录左右对应的indicator宽度
    CGFloat leftIndicatorWidth = [self getIndicatorWidthWithTitle:_childTitles[_leftItemIndex]];
    CGFloat rightIndicatorWidth = [self getIndicatorWidthWithTitle:_childTitles[_rightItemIndex]];
    
    //左右边界的时候，占比清0
    if(_leftItemIndex == _rightItemIndex) {
        relativeLocation = 0;
    }
    //基于从左到右方向（无需考虑滑动方向），计算当前中心轴所处位置的长度
    CGFloat nowIndicatorWidth = leftIndicatorWidth + (rightIndicatorWidth-leftIndicatorWidth)*relativeLocation;
    
    self.indicatorView.frame = CGRectMake(nowIndicatorCenterX-nowIndicatorWidth/2.0-_tabView.contentOffset.x, ORIGIN_Y(self.indicatorView), nowIndicatorWidth, HEIGHT(self.indicatorView));
}

- (void)changeIndicatorFrameByStretch {
    if(_indicatorWidth <= 0) {
        return;
    }
    
    //计算此时body的偏移量在一页中的占比
    CGFloat relativeLocation = (self.bodyView.contentOffset.x/WIDTH(self.bodyView)-_leftItemIndex)/(_rightItemIndex-_leftItemIndex);
    //左右边界的时候，占比清0
    if(_leftItemIndex == _rightItemIndex) {
        relativeLocation = 0;
    }
    
    XXPageTabItemLable *leftTabItem = _tabItems[_leftItemIndex];
    XXPageTabItemLable *rightTabItem = _tabItems[_rightItemIndex];
    
    //当前的frame
    CGRect nowFrame = CGRectMake(0, ORIGIN_Y(self.indicatorView), 0, HEIGHT(self.indicatorView));
    
    //计算宽度
    if(relativeLocation <= 0.5) {
        nowFrame.size.width = _indicatorWidth+_tabItemWidth*(relativeLocation/0.5);
        nowFrame.origin.x = (leftTabItem.center.x-self.tabView.contentOffset.x)-_indicatorWidth/2.0;
    } else {
        nowFrame.size.width = _indicatorWidth+_tabItemWidth*((1-relativeLocation)/0.5);
        nowFrame.origin.x = (rightTabItem.center.x-self.tabView.contentOffset.x)+_indicatorWidth/2.0-nowFrame.size.width;
    }

    self.indicatorView.frame = nowFrame;
}

#pragma mark - Tool
/**
 根据对应文本计算下标线宽度
 */
- (CGFloat)getIndicatorWidthWithTitle:(NSString *)title {
    if(_indicatorStyle == XXPageTabIndicatorStyleDefault || _indicatorStyle == XXPageTabIndicatorStyleStretch) {
        return _indicatorWidth;
    } else {
        if(title.length <= 2) {
            return 40;
        } else {
            return title.length * _tabItemFont.pointSize + 12;
        }
    }
}

/**
 获取color的rgb值
 */
- (NSArray *)getRGBWithColor:(UIColor *)color {
    CGFloat R = 0;
    CGFloat G = 0;
    CGFloat B = 0;
    NSInteger numComponents = CGColorGetNumberOfComponents(color.CGColor);
    if(numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        R = components[0];
        G = components[1];
        B = components[2];
    }
    return @[@(R), @(G), @(B)];
}

#pragma mark - Getter/setter
- (UIView *)bgView {
    if(!_bgView) {
        _bgView = [UIView new];
    }
    return _bgView;
}

- (UIScrollView *)tabView {
    if(!_tabView) {
        _tabView = [UIScrollView new];
        _tabView.showsVerticalScrollIndicator = NO;
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.backgroundColor = _tabBackgroundColor;
        _tabView.delegate = self;
        _tabView.clipsToBounds = YES;
    }
    return _tabView;
}

- (UIView *)separatorView {
    if(!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = _separatorColor;
    }
    return _separatorView;
}

- (UIScrollView *)bodyView {
    if(!_bodyView) {
        _bodyView = [UIScrollView new];
        _bodyView.pagingEnabled = YES;
        _bodyView.showsVerticalScrollIndicator = NO;
        _bodyView.showsHorizontalScrollIndicator = NO;
        _bodyView.delegate = self;
        _bodyView.bounces = _bodyBounces;
        _bodyView.backgroundColor = _bodyBackgroundColor;
        _bodyView.scrollEnabled = _bodyScrollEnabled;
    }
    return _bodyView;
}

- (UIView *)indicatorView {
    if(!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.backgroundColor = _selectedColor;
    }
    return _indicatorView;
}

- (void)setTabBackgroundColor:(UIColor *)tabBackgroundColor {
    _tabBackgroundColor = tabBackgroundColor;
    self.tabView.backgroundColor = _tabBackgroundColor;
}

- (void)setBodyBackgroundColor:(UIColor *)bodyBackgroundColor {
    _bodyBackgroundColor = bodyBackgroundColor;
    self.bodyView.backgroundColor = _bodyBackgroundColor;
}

- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    if(selectedTabIndex >= 0 && selectedTabIndex < _numberOfTabItems && _selectedTabIndex != selectedTabIndex) {
        [self changeSelectedItemToNextItem:selectedTabIndex];
        _selectedTabIndex = selectedTabIndex;
        _lastSelectedTabIndex = selectedTabIndex;
        [self layoutIndicatorViewWithStyle];
        [self resetMainView];
        [self initMainView];
        self.bodyView.contentOffset = CGPointMake(WIDTH(self)*_selectedTabIndex, 0);
        
        if(_titleStyle == XXPageTabTitleStyleGradient) {
            [self resetTabItemScale];
        }
    }
}

- (void)setSelectedTabIndexWithAnimation:(NSInteger)selectedTabIndex {
    if(selectedTabIndex >= 0 && selectedTabIndex < _numberOfTabItems && _selectedTabIndex != selectedTabIndex) {
        //防止快速点击
        if(_tabView.userInteractionEnabled) {
            UIView *tabItem = [_tabItems objectAtIndex:selectedTabIndex];
            [self changeChildControllerOnClick:tabItem.gestureRecognizers[0]];
        }
    }
}

- (void)setUnSelectedColor:(UIColor *)unSelectedColor {
    _unSelectedColor = unSelectedColor;
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        XXPageTabItemLable *tabItem = _tabItems[i];
        tabItem.textColor = i==_selectedTabIndex?_selectedColor:_unSelectedColor;
    }
    NSArray *rgb = [self getRGBWithColor:_unSelectedColor];
    _unSelectedColorR = [rgb[0] floatValue];
    _unSelectedColorG = [rgb[1] floatValue];
    _unSelectedColorB = [rgb[2] floatValue];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    XXPageTabItemLable *tabItem = _tabItems[_selectedTabIndex];
    tabItem.textColor = _selectedColor;
    self.indicatorView.backgroundColor = _selectedColor;
    
    NSArray *rgb = [self getRGBWithColor:_selectedColor];
    _selectedColorR = [rgb[0] floatValue];
    _selectedColorG = [rgb[1] floatValue];
    _selectedColorB = [rgb[2] floatValue];
}

- (void)setBodyBounces:(BOOL)bodyBounces {
    _bodyBounces = bodyBounces;
    self.bodyView.bounces = _bodyBounces;
}

- (void)setTabItemFont:(UIFont *)tabItemFont {
    _tabItemFont = tabItemFont;
    for(NSInteger i = 0; i < _numberOfTabItems; i++) {
        XXPageTabItemLable *tabItem = _tabItems[i];
        tabItem.font = _tabItemFont;
    }
}

- (void)setTitleStyle:(XXPageTabTitleStyle)titleStyle {
    if(_titleStyle == XXPageTabTitleStyleDefault) {
        _titleStyle = titleStyle;
        if(_titleStyle == XXPageTabTitleStyleGradient) {
            [self resetTabItemScale];
        }
    }
}

- (void)setIndicatorStyle:(XXPageTabIndicatorStyle)indicatorStyle {
    if(_indicatorStyle == XXPageTabIndicatorStyleDefault) {
        _indicatorStyle = indicatorStyle;
//        [self addIndicatorViewWithStyle]; 
    }
}

- (void)setMinScale:(CGFloat)minScale {
    if(minScale > 0 && minScale <= 1) {
        _minScale = minScale;
        if(_titleStyle == XXPageTabTitleStyleGradient) {
            [self resetTabItemScale];
        }
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    self.separatorView.backgroundColor = _separatorColor;
}

- (void)setBodyScrollEnabled:(BOOL)bodyScrollEnabled {
    _bodyScrollEnabled = bodyScrollEnabled;
    self.bodyView.scrollEnabled = _bodyScrollEnabled;
}

@end
