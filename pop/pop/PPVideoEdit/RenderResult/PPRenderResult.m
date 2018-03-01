//
//  PPRenderResult.m
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderResult.h"
#import "PPRenderLayerResult.h"
#import "PPRenderEmojiResult.h"
#import "PPRenderTextResult.h"

@interface PPRenderResult()
@property (nonatomic, assign, readwrite) NSInteger tagId;
@property (nonatomic, assign, readwrite) PPRenderResultType type;

@end


@implementation PPRenderResult

static NSInteger kLastTag = 666;

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.tagId = kLastTag + 1;
        kLastTag++;
    }
    return self;
}

+ (instancetype)renderResultWithType:(PPRenderResultType )type {
    PPRenderResult *result = nil;
    switch (type) {
        case PPRenderResultTypeLayer:
        {
            PPRenderLayerResult *layerResult = [[PPRenderLayerResult alloc] initPrivate];
            result = layerResult;
        }
            break;
        case PPRenderResultTypeEmoji:
        {
            PPRenderEmojiResult *emojiResult = [[PPRenderEmojiResult alloc] initPrivate];
            result = emojiResult;
        }
            break;
        case PPRenderResultTypeText:
        {
            PPRenderTextResult *textResult = [[PPRenderTextResult alloc] initPrivate];
            result = textResult;
        }
            break;
        default:
        {
            NSLog(@"error: unknown PPRenderResultType: %d",type);
        }
            break;
    }    
    result.type = type;
    return result;
}


@end
