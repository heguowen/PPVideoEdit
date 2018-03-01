//
//  PPImageSourceView.h
//  pop
//
//  Created by neil on 2017/9/13.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPVideoEditDefines.h"
#import "PPRenderResult.h"
#import "PPVideoEditBaseView.h"

@class PPRenderSourceView;
@protocol PPRenderSourceViewDelegate <PPVideoEditBaseViewProtocol>


/**
 源视图代理方法

 @param view 当前处理的视图
 @param result 渲染结果，可能是一个表情，可能是笔画，也可能是文字，该值可能为nil.
 */
- (void)sourceView:(PPRenderSourceView *)view didOutput:(PPRenderResult *)result;

@end

@interface PPRenderSourceView : PPVideoEditBaseView

@property (nonatomic, weak) id<PPRenderSourceViewDelegate> delegate;

+ (PPRenderSourceView *)sourceViewWithSourceType:(PPRenderSourceType)type;

@end



