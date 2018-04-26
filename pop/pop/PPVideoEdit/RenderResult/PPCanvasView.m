//
//  PPCanvasView.m
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPCanvasView.h"
#import "PPImageEditView.h"
#import "PPRenderResultDefines.h"

@interface PPCanvasView() <PPImageEditViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) PPRenderResult *lastEditItem;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) NSMutableArray<PPRenderResult *> *renderModels;
@property (atomic, assign) BOOL isTheSameTouchSession; //是否处于同一次touchBengin touchEnd会话之间

@end

@implementation PPCanvasView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.renderModels = [NSMutableArray<PPRenderResult *> arrayWithCapacity:10];
        self.deleteBtn.hidden = YES;
        self.clipsToBounds = YES;
        self.isTheSameTouchSession = NO; //减少手势回调方法调用的次数
        [self addGestures];
        [self registerNotification];
    }
    return self;
}

- (void)addGestures {
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTouch:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTouch:)];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderTextResultDidChangeStateNotify:) name:PPRenderTextResultDidChangeStateNotification object:nil];
}

- (void)renderTextResultDidChangeStateNotify:(NSNotification *)notification {
    PPRenderTextResult *textResult = notification.object;
    PPImageEditView *view = [self getEditViewFromResult:textResult];
    if (!view) {
        return;
    }
    switch (textResult.currentState) {
        case PPRenderTextStateShow:
            view.hidden = NO;
            break;
        case PPRenderTextStateEditing:
            view.hidden = YES;
            break;
        case PPRenderTextStateRemove:
            [view removeFromSuperview];
            [_renderModels removeObject:textResult];
            break;
        default:
            NSLog(@"error: undefined pprenderstate:%@",@(textResult.currentState));
            break;
    }
}

- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:deleteBtn];
        [deleteBtn setImage:[UIImage imageNamed:@"edit_delete_btn"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf).offset(-15);
        }];
        _deleteBtn = deleteBtn;
    }
    return _deleteBtn;
}

- (void)render:(PPRenderResult *)result {
    if (!result) {
        return;
    }
    
    switch (result.type) {
        case PPRenderResultTypeLayer:
        {
            [self.layer insertSublayer:result.content atIndex:0];
            [self.renderModels addObject:result];
        }
            break;
        case PPRenderResultTypeEmoji:
        case PPRenderResultTypeText:
        {
            PPImageEditView *imageEditView = [[PPImageEditView alloc] initWithFrame:result.frame];
            imageEditView.tag = result.tagId;
            imageEditView.delegate = self;
            [imageEditView render:result];
            
            [self addSubview:imageEditView];
            [self.renderModels addObject:result];
        }
        default:
            break;
    }
}

- (UIImage *)generateImage {
    if (self.renderModels.count == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];

    UIImage *snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  snapshotImageFromMyView;
}

#pragma mark - PPImageEditViewDelegate
- (void)imageEditViewDidTap:(PPImageEditView *)editView {
    PPRenderResult *currentResult;
    for (PPRenderResult *result in self.renderModels) {
        if (result.tagId == editView.tag) {
            currentResult = result;
            break;
        }
    }
    if (!currentResult) {
        NSLog(@"error,operating result not found!");
        return;
    }
    if (currentResult.type != PPRenderResultTypeText) {
        NSLog(@"not tap on text image");
        return;
    }
    self.lastEditItem = currentResult;
    [self bringSubviewToFront:editView];
    
    PPRenderTextResult *textResult = (PPRenderTextResult *)currentResult;
    if([self.delegate respondsToSelector:@selector(canvasView:didTapText:)]) {
        [self.delegate canvasView:self didTapText:textResult];
    }
}

- (void)imageEditViewDidDragStart:(PPImageEditView *)editView {
    self.deleteBtn.hidden = NO;
    self.lastEditItem = [self getResultFromEditView:editView];
    [self bringSubviewToFront:editView];
    [self editBegin];
}

- (void)imageEditViewDidDragMoving:(PPImageEditView *)editView {
    if (self.deleteBtn.hidden == YES) {
        self.deleteBtn.hidden = NO;
    }
    
}

- (BOOL)imageEditView:(PPImageEditView *)editView willMoveWithVector:(CGPoint)vector {
    return YES;
}


- (void)imageEditViewDidDragEnd:(PPImageEditView *)editView withPointInWindow:(CGPoint)point{
    [self editEnd];
    
    self.deleteBtn.transform = CGAffineTransformIdentity;
    self.deleteBtn.hidden = YES;


    if (CGRectContainsPoint(self.deleteBtn.frame, point)) {
        PPRenderResult *result = [self getResultFromEditView:editView];
        [self.renderModels removeObject:result];
        [editView removeFromSuperview];
        editView = nil;
    }
}

- (void)onViewTouch:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self editBegin];
    }
    BOOL touchEnd = (gesture.state == UIGestureRecognizerStateEnded) ||
                    (gesture.state == UIGestureRecognizerStateFailed) ||
                    (gesture.state == UIGestureRecognizerStateCancelled);
    
    if (touchEnd) {
        [self editEnd];
    }
    
    PPImageEditView *editView = nil;
    if (self.isTheSameTouchSession) {
        editView = [self getEditViewFromResult:self.lastEditItem];
    } else {
        self.isTheSameTouchSession = YES;
        
        NSInteger numberTouchs = gesture.numberOfTouches;
        if (numberTouchs != 2) {
            return;
        }
        CGPoint firstPoint = [gesture locationOfTouch:0 inView:self];
        CGPoint secondPoint = [gesture locationOfTouch:1 inView:self];
        editView = [self getRelatedEditViewFromFirstPoint:firstPoint secondPoint:secondPoint];
    }
    if (!editView) {
        return;
    }
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        [self onView:editView pinch:(UIPinchGestureRecognizer *)gesture];
    } else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]){
        [self onView:editView rotation:(UIRotationGestureRecognizer *)gesture];
    } else {
        NSLog(@"unrecognize gesture : %@",gesture);
    }
    if (touchEnd) {
        self.isTheSameTouchSession = NO;
    }
}

- (void)onView:(PPImageEditView *)editView pinch:(UIPinchGestureRecognizer *)gesture {
    editView.scaleValue *= gesture.scale;
    editView.transform = CGAffineTransformScale(editView.transform, gesture.scale, gesture.scale);
    gesture.scale = 1.0f;
    [self bringSubviewToFront:editView];
    [editView setNeedsLayout]; // make editView call layoutsubview: fun
}

- (void)onView:(PPImageEditView *)editView rotation:(UIRotationGestureRecognizer *)gesture {
    [self bringSubviewToFront:editView];
    editView.transform = CGAffineTransformRotate(editView.transform, gesture.rotation);
    gesture.rotation = 0;
}

#pragma mark - private func
- (void)editBegin {
    if ([self.delegate respondsToSelector:@selector(canvasViewBeginEdit:)]) {
        [self.delegate canvasViewBeginEdit:self];
    }
}

- (void)editEnd {
    if ([self.delegate respondsToSelector:@selector(canvasViewEndEdit:
                                                    )]) {
        [self.delegate canvasViewEndEdit:self];
    }
}


- (CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    CGFloat distance = 0.0f;
    distance = sqrtf((point1.x - point2.x)*(point1.x - point2.x) + (point1.y - point2.y)*(point1.y - point2.y));
    return distance;
}

- (PPRenderResult *)getResultFromEditView:(PPImageEditView *)editView {
    PPRenderResult *currentResult = nil;
    for (PPRenderResult *result in self.renderModels) {
        if (result.tagId == editView.tag) {
            currentResult = result;
            break;
        }
    }
    return currentResult;
}

- (PPImageEditView *)getEditViewFromResult:(PPRenderResult *)result {
    PPImageEditView *editView = nil;
    for (PPImageEditView *view in self.subviews) {
        if ([view isKindOfClass:[PPImageEditView class]] && (view.tag == result.tagId)) {
            editView = view;
            break;
        }
    }
    return editView;
}

- (PPImageEditView *)getRelatedEditViewFromFirstPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint {
    NSMutableSet<PPImageEditView *> *mutableSet = [NSMutableSet set];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[PPImageEditView class]]) {
            CGPoint leftTopPoint = view.frame.origin;
            CGPoint rightBottomPoint = CGPointMake(leftTopPoint.x + view.width, leftTopPoint.y + view.height);
            BOOL intersect = isLineIntersectRectangle(firstPoint.x, firstPoint.y, secondPoint.x, secondPoint.y, leftTopPoint.x, leftTopPoint.y, rightBottomPoint.x, rightBottomPoint.y);
            if (intersect) {
                [mutableSet addObject:(PPImageEditView *)view];
            }
        }
    }
    PPImageEditView *lastEditView = [self getEditViewFromResult:self.lastEditItem];
    if ([mutableSet containsObject:lastEditView]) {
        return lastEditView;
    } else {
        PPImageEditView *editView = [mutableSet anyObject];
        self.lastEditItem = [self getResultFromEditView:editView];
        return editView;
    }
}

bool isLineIntersectRectangle(float linePointX1,
                         float linePointY1,
                         float linePointX2,
                         float linePointY2,
                         float rectangleLeftTopX,
                         float rectangleLeftTopY,
                         float rectangleRightBottomX,
                         float rectangleRightBottomY){
    float  lineHeight = linePointY1 - linePointY2;
    float lineWidth = linePointX2 - linePointX1;  // 计算叉乘
    float c = linePointX1 * linePointY2 - linePointX2 * linePointY1;
    if ((lineHeight * rectangleLeftTopX + lineWidth * rectangleLeftTopY + c >= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleRightBottomY + c <= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleLeftTopY + c <= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleRightBottomY + c >= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleRightBottomY + c >= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleLeftTopY + c <= 0)
        || (lineHeight * rectangleLeftTopX + lineWidth * rectangleRightBottomY + c <= 0 && lineHeight * rectangleRightBottomX + lineWidth * rectangleLeftTopY + c >= 0))
    {
        
        if (rectangleLeftTopX > rectangleRightBottomX) {
            float temp = rectangleLeftTopX;
            rectangleLeftTopX = rectangleRightBottomX;
            rectangleRightBottomX = temp;
        }
        if (rectangleLeftTopY < rectangleRightBottomY) {
            float temp1 = rectangleLeftTopY;
            rectangleLeftTopY = rectangleRightBottomY;
            rectangleRightBottomY = temp1;
        }
        if ((linePointX1 < rectangleLeftTopX && linePointX2 < rectangleLeftTopX)
            || (linePointX1 > rectangleRightBottomX && linePointX2 > rectangleRightBottomX)
            || (linePointY1 > rectangleLeftTopY && linePointY2 > rectangleLeftTopY)
            || (linePointY1 < rectangleRightBottomY && linePointY2 < rectangleRightBottomY)) {
            return false;
        } else {
            return true;
        }
    } else {
        return false;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    //rotation and pinch can be effect simultaneous
    if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return YES;
    }
    if ([otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
