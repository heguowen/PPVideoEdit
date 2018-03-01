//
//  Helper+Time.h
//  guimiquan
//
//  Created by Chen Rui on 11/20/14.
//  Copyright (c) 2014 Vanchu. All rights reserved.
//

#import "PPHelper.h"

@interface PPHelper (Time)

+ (void)timeSetTimeout:(float)seconds withFinishBlock:(void (^)())finishBlock;
+ (NSTimeInterval)timeNow;

+ (NSString *)formatMMSSForSeconds:(NSInteger)seconds;

@end
