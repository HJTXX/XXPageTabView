//
//  XXLineChartDataItem.m
//  XXChartDemo
//
//  Created by HJTXX on 2017/2/20.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import "XXLineChartDataItem.h"

@implementation XXLineChartDataItem

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y {
    self = [super init];
    if(self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point {
    self = [super init];
    if(self) {
        _x = point.x;
        _y = point.y;
    }
    return self;
}

@end
