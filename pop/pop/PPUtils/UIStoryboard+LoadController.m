//
//  UIStoryboard+LoadController.m
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "UIStoryboard+LoadController.h"

@implementation UIStoryboard (LoadController)

+ (UIViewController *)loadControllerWithStoryBoardName:(NSString *)storyBoardName withController:(Class)controller {
    return [[UIStoryboard storyboardWithName:storyBoardName bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(controller)];
}

@end
