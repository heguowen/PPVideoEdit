//
//  Helper+Time.m
//  guimiquan
//
//  Created by Chen Rui on 11/20/14.
//  Copyright (c) 2014 Vanchu. All rights reserved.
//

#import "PPHelper+Time.h"

@implementation PPHelper (Time)

+ (void)timeSetTimeout:(float)seconds withFinishBlock:(void (^)())finishBlock {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), finishBlock);
}

+ (NSTimeInterval)timeNow {
	return [NSDate date].timeIntervalSince1970;
}

+ (NSString *)formatMMSSForSeconds:(NSInteger)seconds {
    NSInteger second = seconds % 60;
    NSInteger minute = seconds / 60;
    return [NSString stringWithFormat:@"%.2d:%.2d",(int)minute,(int)second];
}


@end
