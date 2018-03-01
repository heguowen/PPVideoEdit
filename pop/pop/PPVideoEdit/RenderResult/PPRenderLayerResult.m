//
//  PPRenderLayerResult.m
//  pop
//
//  Created by neil on 2017/10/9.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderLayerResult.h"

@interface PPRenderLayerResult()
{
    CALayer *_layer;
}
@end

@implementation PPRenderLayerResult
@dynamic content;

- (void)setContent:(CALayer *)content {
    _layer = content;
}

- (CALayer *)content {
    return _layer;
}

@end
