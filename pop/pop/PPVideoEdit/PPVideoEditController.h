//
//  PPVideoEditController.h
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PPVideoEditDefines.h"

@interface PPVideoEditController : PPBasicController

- (void)loadViewWithPHAsset:(PHAsset *)asset;

@end
