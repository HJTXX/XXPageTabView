//
//  XXPageTabItemLable.m
//  XXPageTabDemo
//
//  Created by HJTXX on 2017/3/3.
//  Copyright © 2017年 HJTXX. All rights reserved.
//

#import "XXPageTabItemLable.h"

@implementation XXPageTabItemLable

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if([_fillColor isKindOfClass:[UIColor class]]) {
        [_fillColor setFill];
        UIRectFillUsingBlendMode(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*_process, rect.size.height), kCGBlendModeSourceIn);
    }
}

- (void)setProcess:(CGFloat)process {
    _process = process;
    [self setNeedsDisplay];
}

@end
