//
//  PPRenderTextResult.m
//  pop
//
//  Created by neil on 2017/10/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderTextResult.h"

@interface PPRenderTextResult()
{
    UIImage *_content;
    PPRenderTextState _currentState;
}
@end

@implementation PPRenderTextResult


@dynamic content;

- (void)setContent:(UIImage *)content {
    _content = content;
}

- (UIImage *)content {
    return _content;
}

- (PPRenderTextState)currentState {
    return _currentState;
}

- (void)changeCurrentState:(PPRenderTextState)state {
    _currentState = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:PPRenderTextResultDidChangeStateNotification object:self];
}


@end
