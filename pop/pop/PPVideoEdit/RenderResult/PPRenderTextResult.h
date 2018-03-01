//
//  PPRenderTextResult.h
//  pop
//
//  Created by neil on 2017/10/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPRenderResult.h"


typedef NS_ENUM(NSInteger,PPRenderTextState) {
    PPRenderTextStateShow    = 0,
    PPRenderTextStateEditing = 1,
    PPRenderTextStateRemove  = 2,
};

@interface PPRenderTextResult : PPRenderResult
@property (nonatomic, strong) UIImage *content;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDictionary *attributes;


@property (nonatomic, assign, readonly)PPRenderTextState currentState;

- (void)changeCurrentState:(PPRenderTextState)state;

@end
