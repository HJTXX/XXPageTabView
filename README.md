# XXPageTabView
日常切换栏组件，几行代码即可完美实现网易云音乐，今日头条，微博等切换栏效果。


# 使用方法
通过设置titleStyle和indicatorStyle最多支持九种组合效果，后续还会增加其他效果：
<pre>self.pageTabView.titleStyle = XXPageTabTitleStyleDefault;
self.pageTabView.indicatorStyle = XXPageTabIndicatorStyleDefault;
</pre>
在实际使用中，切换之后往往需要刷新当前页的数据，可以在代理方法中获取到最终页索引后进行数据刷新：
<pre>- (void)pageTabViewDidEndChange {
    NSLog(@"#####%d", self.pageTabView.selectedTabIndex);
}
</pre>

# 最后
如果在使用中遇到任何问题或者建议，欢迎issues，我会尽快处理，如果帮助到你，你懂的😏。


