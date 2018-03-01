//
//  DSToast.h
//  DSToast
//
//  Created by LS on 8/18/15.
//  Copyright (c) 2015 LS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GMToastDurationShort 0.7

@interface PPToast : UILabel

+ (instancetype)make:(NSString *)text;
+ (instancetype)make:(NSString *)text complete:(void (^)())completeCallback;

- (void)show;
- (void)showWithDuration:(CGFloat)duration;
@end
