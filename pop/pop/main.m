//
//  main.m
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }@catch(NSException *exception){
            NSLog(@"exception reason is %@",exception.reason);
        }
    }
}
