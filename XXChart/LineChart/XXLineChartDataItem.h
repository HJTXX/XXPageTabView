//
//  XXLineChartDataItem.h
//  XXChartDemo
//
//  Created by HJTXX on 2017/2/20.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XXLineChartDataItem : NSObject

@property (nonatomic, readonly, assign) CGFloat x;
@property (nonatomic, readonly, assign) CGFloat y;

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y;
- (instancetype)initWithPoint:(CGPoint)point;

@end
