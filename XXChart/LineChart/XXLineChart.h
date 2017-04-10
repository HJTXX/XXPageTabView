//
//  XXLineChart.h
//  XXChartDemo
//
//  Created by HJTXX on 2017/2/20.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXLineChartDataItem.h"

@interface XXLineChart : UIView

@property (nonatomic, copy) NSArray<XXLineChartDataItem *> *dataItems;

- (void)strokeChart;

@end
