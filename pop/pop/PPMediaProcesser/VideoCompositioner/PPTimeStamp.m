//
//  PPTimeStamp.m
//  pop
//
//  Created by neil on 2017/9/18.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPTimeStamp.h"

@implementation PPTimeStamp

- (instancetype)initWithStart:(CGFloat)start duration:(CGFloat)duration {
    self = [super init];
    if (self) {
        _start = start;
        _duration = duration;
    }
    return self;
}

+ (instancetype)stampWithStart:(CGFloat)start
                      duration:(CGFloat)duration {
    PPTimeStamp *stamp = [[PPTimeStamp alloc] initWithStart:start duration:duration];
    return stamp;
}

@end
