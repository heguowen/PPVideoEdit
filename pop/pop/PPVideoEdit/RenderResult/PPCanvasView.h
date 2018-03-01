//
//  PPCanvasView.h
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "PPRenderResult.h"
#import "PPRenderTextResult.h"

@protocol PPCanvasViewDelegate;

/**
 画布视图，表情，文字以及绘制，最终均会展示在该视图上
 */
@interface PPCanvasView : UIView
@property (nonatomic, weak) id<PPCanvasViewDelegate> delegate;


- (void)render:(PPRenderResult *)result;
/**
 将所有的操作生成为一张图片

 @return   生成的图片
 */
- (UIImage *)generateImage;

- (void)removeObserver;

@end

@protocol PPCanvasViewDelegate<NSObject>

- (void)canvasView:(PPCanvasView *)canvasView didTapText:(PPRenderTextResult *)text;

- (void)canvasViewBeginEdit:(PPCanvasView *)canvasView;

- (void)canvasViewEndEdit:(PPCanvasView *)canvasView;

@end
