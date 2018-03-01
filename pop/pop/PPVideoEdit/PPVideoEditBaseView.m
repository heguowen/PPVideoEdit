//
//  PPVideoEditBaseView.m
//  pop
//
//  Created by neil on 2017/9/26.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPVideoEditBaseView.h"

@implementation PPVideoEditBaseView

- (BOOL)useSelfToolBar {
    /// implement by subclass;
    return NO;
}

- (void)showSelf {
    /// implement by subclass;
    self.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(editViewWillShow:)]) {
        [self.delegate editViewWillShow:self];
    }
}

- (void)hiddenSelf {
    /// implement by subclass;
    self.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(editViewWillHidden:)]) {
        [self.delegate editViewWillHidden:self];
    }
}

@end
