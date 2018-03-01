//
//  PPTestCase.m
//  pop
//
//  Created by neil on 2017/10/10.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPTestCase.h"

@implementation PPTestCase

+ (instancetype)sharedCase {
    static PPTestCase *instance = nil;
    if (!instance) {
        instance = [[self class] new];
    }
    return instance;
}

@end
