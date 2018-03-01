//
//  PPTimeStamp.h
//  pop
//
//  Created by neil on 2017/9/18.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define  kCMTimeScale  600.0f

@interface PPTimeStamp : NSObject


@property (nonatomic, assign, readonly) CGFloat start;
@property (nonatomic, assign, readonly) CGFloat duration;

/**
 @param start 开始时间，单位是s
 @param duration 时长，单位是s
 @return 时间戳对象
 */
- (instancetype)initWithStart:(CGFloat)start
                     duration:(CGFloat)duration;

+ (instancetype)stampWithStart:(CGFloat)start
                      duration:(CGFloat)duration;




@end
