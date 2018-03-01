//
//  PPDrawingView.m
//  PPDrawingBoard
//
//  Created by AVGD-Jarvi on 17/4/2.
//  Copyright © 2017年 Jarvi. All rights reserved.
//

#import "PPDrawSourceView.h"
#import "PPRenderResultDefines.h"
#import "PPDrawLayer.h"

@interface PPDrawSourceView ()
{
    UIView *_toolBar;
    UIButton *_revokrBtn;
}
@property (nonatomic, assign) BOOL isFirstTouch;//区分点击与滑动手势

@property (nonatomic, strong) PPDrawLayer *currentDrawLayer;

@property (nonatomic, strong) NSMutableArray *layerArray;//当前创建的path集合

@end

@implementation PPDrawSourceView

- (instancetype)init {
    if (self = [super init]) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    self.userInteractionEnabled = YES;
    self.frame = [UIScreen mainScreen].bounds;
    self.layerArray = [[NSMutableArray alloc] init];
    [self addLayersObserver];
    
    [self setupToolBar];
}

- (void)dealloc {
    [self removeLayersObserver];
}

#pragma mark - API
- (void)revokeBtnClick:(UIButton *)btn {
    [self revoke];
}

- (void)showSelf {
    [super showSelf];
}

- (void)hiddenSelf {
    [super hiddenSelf];
}

- (BOOL)useSelfToolBar {
    // !!!must implement by subclass
    
    return YES;
}

- (void)setupToolBar {
    UIView *toolBar = [[UIView alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:toolBar];
    _toolBar = toolBar;
    __weak typeof(self) weakSelf = self;

    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(10);
        make.leading.equalTo(weakSelf).offset(20);
        make.trailing.equalTo(weakSelf).offset(-20);
        make.height.mas_equalTo(@30);
    }];
    
    
    UIButton *revokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBar addSubview:revokeBtn];
    revokeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [revokeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(toolBar);
        make.top.equalTo(toolBar);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [revokeBtn setTitle:@"撤销" forState:UIControlStateNormal];
    [revokeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [revokeBtn addTarget:self action:@selector(onRevokeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    revokeBtn.hidden = YES;
    _revokrBtn = revokeBtn;
    
    UIImageView *penImageView = [[UIImageView alloc] init];
    penImageView.image = [UIImage imageNamed:@"edit_pen_icon"];
    [toolBar addSubview:penImageView];
    [penImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toolBar);
        make.center.equalTo(toolBar);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBar addSubview:completeBtn];
//    completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(toolBar);
        make.top.equalTo(toolBar);
    }];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(onCompleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - private func
- (BOOL)revoke {
    if (!self.currentDrawLayer) {
        return NO;
    }
    
    [self.currentDrawLayer removeFromSuperlayer];
    [[self mutableArrayValueForKey:@"layerArray"] removeObject:self.currentDrawLayer];
    self.currentDrawLayer = [self.layerArray lastObject];
    return YES;
}

- (void)addLayersObserver{
    [self addObserver:self forKeyPath:@"layerArray" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeLayersObserver{
    [self removeObserver:self forKeyPath:@"layerArray"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    _revokrBtn.hidden = (self.layerArray.count == 0);
}

#pragma mark - click event
- (void)onRevokeBtnClick:(UIButton *)sender {
    [self revoke];
}

- (void)onCompleteBtnClick:(UIButton *)sender {
    [self hiddenSelf];
}


#pragma mark - touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isFirstTouch = YES;//是否第一次点击屏幕
    
    _toolBar.hidden = YES;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    if (self.isFirstTouch) {
        PPDrawLayer *drawLayer = [PPDrawLayer layerWithStartPoint:currentPoint];
        drawLayer.frame = self.bounds;
        self.currentDrawLayer = drawLayer;
        if ([self.delegate respondsToSelector:@selector(sourceView:didOutput:)]) {
            PPRenderResult *result = [PPRenderResult renderResultWithType:PPRenderResultTypeLayer];
            result.content = drawLayer;
            [self.delegate sourceView:self didOutput:result];
        }
    } else {
        [self.currentDrawLayer updatePoint:currentPoint];
        [self.currentDrawLayer setNeedsDisplay];
    }
    
    self.isFirstTouch = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.layerArray containsObject:self.currentDrawLayer] && !self.isFirstTouch) {
        //这种方式添加  才会触发kvo
        [[self mutableArrayValueForKey:@"layerArray"] addObject:self.currentDrawLayer];
    }
    _toolBar.hidden = NO;
}

@end
