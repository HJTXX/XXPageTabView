# XXPageTabView
主页菜单切换栏组件，几行代码即可完美实现网易云音乐，今日头条，微博等切换栏效果。


# 使用方法
通过设置titleStyle和indicatorStyle最多支持九种组合效果，后续还会增加其他效果：
<pre>typedef NS_ENUM(NSInteger, XXPageTabTitleStyle) {
    XXPageTabTitleStyleDefault, //正常
    XXPageTabTitleStyleGradient, //渐变
    XXPageTabTitleStyleBlend //填充
};

typedef NS_ENUM(NSInteger, XXPageTabIndicatorStyle) {
    XXPageTabIndicatorStyleDefault, //正常，自定义宽度
    XXPageTabIndicatorStyleFollowText, //跟随文本长度变化
    XXPageTabIndicatorStyleStretch //拉伸
};

self.pageTabView.titleStyle = XXPageTabTitleStyleDefault;
self.pageTabView.indicatorStyle = XXPageTabIndicatorStyleDefault;
</pre>
在实际使用中，切换之后往往需要刷新当前页的数据，可以在代理方法中获取到最终页索引后对指定控制器进行数据刷新：
<pre>- (void)pageTabViewDidEndChange {
    NSLog(@"#####%d", self.pageTabView.selectedTabIndex);
}
</pre>

# V1.1 更新
<pre>优化加载模式，初始时仅加载当前Index，滑动时预加载左右两侧的子控制器，降低资源消耗和渲染时间。</pre>
 
# V1.2 更新
<pre>
1.增加可实时修改子控制器与标题方法（适用于菜单编辑与排序）
2.优化多控制器时，长距离点击切换由于预加载造成的卡顿问题（现在长距离点击切换时，只会预加载目标子控制器）
3.增加设置selectedIndex动画效果（用于按钮切换上下页）
</pre>

# 最后
如果在使用中遇到任何问题或者建议，欢迎issues，我会尽快处理，如果帮助到你，你懂的😏。
