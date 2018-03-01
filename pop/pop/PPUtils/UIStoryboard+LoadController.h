//
//  UIStoryboard+LoadController.h
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (LoadController)

+ (UIViewController *)loadControllerWithStoryBoardName:(NSString *)storyBoardName withController:(Class)controller;

@end
