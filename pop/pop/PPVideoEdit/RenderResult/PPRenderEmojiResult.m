//
//  PPRenderEmojiResult.m
//  pop
//
//  Created by neil on 2017/10/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderEmojiResult.h"

@interface PPRenderEmojiResult()
{
    UIImage *_content;
}
@end

@implementation PPRenderEmojiResult

@dynamic content;

- (UIImage *)content {
    return _content;
}

- (void)setContent:(UIImage *)content {
    _content = content;
}

@end
