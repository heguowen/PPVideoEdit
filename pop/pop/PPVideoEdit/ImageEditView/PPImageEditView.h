//
//  PPImageEditView.h
//  pop
//
//  Created by neil on 2017/9/25.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRenderResult.h"

@protocol PPImageEditViewDelegate;
@interface PPImageEditView : UIView
@property (nonatomic, weak) id<PPImageEditViewDelegate> delegate;
//@property (nonatomic, assign) CGSize currentSize;

@property (nonatomic, assign) CGFloat scaleValue;
//- (void)setImage:(UIImage *)image;

- (void)render:(PPRenderResult *)result;

@end


@protocol PPImageEditViewDelegate<NSObject>

@required
- (BOOL)imageEditView:(PPImageEditView *)editView willMoveWithVector:(CGPoint)vector;

@optional
- (void)imageEditViewDidTap:(PPImageEditView *)editView;


//- (void)imageEditView:(PPImageEditView *)editView didPinch:(UIPinchGestureRecognizer *)pinch;
//
//- (void)imageEditView:(PPImageEditView *)editView didRotation:(UIRotationGestureRecognizer *)rotation;

- (void)imageEditViewDidDragStart:(PPImageEditView *)editView;


- (void)imageEditViewDidDragMoving:(PPImageEditView *)editView;

- (void)imageEditViewDidDragEnd:(PPImageEditView *)editView withPointInWindow:(CGPoint)point;



@end
