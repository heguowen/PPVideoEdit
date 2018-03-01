//
//  PPImageSourceView.m
//  pop
//
//  Created by neil on 2017/9/13.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderSourceView.h"
#import "PPDrawSourceView.h"
#import "PPTextSourceView.h"
#import "PPEmojiSourceView.h"

@interface PPRenderSourceView()
{
    __weak id<PPRenderSourceViewDelegate> _delegate;
}
@end

@implementation PPRenderSourceView
@dynamic delegate;

+ (PPRenderSourceView *)sourceViewWithSourceType:(PPRenderSourceType)type {
    PPRenderSourceView *source = nil;
    switch (type) {
        case PPRenderSourceTypeEmoji:
            source = [[PPEmojiSourceView alloc] initWithFrame:CGRectZero];
            break;
        case PPRenderSourceTypeDraw:
            source = [[PPDrawSourceView alloc] initWithFrame:CGRectZero];
            break;
        case PPRenderSourceTypeText:
            source = [[PPTextSourceView alloc] initWithFrame:CGRectZero];
            break;
        default:
            break;
    }
    return source;
}

//- (void)showSelf {
//    [super showSelf];
//}
//
//- (void)hiddenSelf {
//    [super hiddenSelf];
//}

//- (BOOL)useSelfToolBar {
//    // !!!must implement by subclass
//    return YES;
//}

- (void)setDelegate:(id<PPRenderSourceViewDelegate>)delegate {
    _delegate = delegate;
}

- (id<PPRenderSourceViewDelegate> )delegate {
    return _delegate;
}

@end
