//
//  PPImageEditView.m
//  pop
//
//  Created by neil on 2017/9/25.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPImageEditView.h"
#import "PPHelper+Draw.h"
#import "PPRenderResult.h"
#import "PPRenderTextResult.h"
@interface PPImageEditView()<UIGestureRecognizerDelegate>
{
    PPRenderResult *_render;
    UIFont *_initialFont;
    CGSize _initialSize;
    CGFloat _lastScaleValue;
}

@property (nonatomic, strong) UIImageView *contentView;

@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinch;
@property (strong, nonatomic) IBOutlet UIRotationGestureRecognizer *rotation;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *pan;

@end

@implementation PPImageEditView


#pragma mark - gesture handle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _initialSize = CGSizeZero;
        self.scaleValue = 1.0f;
        self.clipsToBounds = YES;
//        self.userInteractionEnabled = NO;
        [self loadView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadView];
    //set priority rotation > pinch > pan;
    [self.pan requireGestureRecognizerToFail:self.rotation];
    [self.pan requireGestureRecognizerToFail:self.pinch];
    [self.pinch requireGestureRecognizerToFail:self.rotation];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![_render isKindOfClass:[PPRenderTextResult class]]) {
        return;
    }
    if (_lastScaleValue == self.scaleValue) {
        return;
    }
    _lastScaleValue = self.scaleValue;
    
    PPRenderTextResult *textResult = (PPRenderTextResult *)_render;
    
    if (CGSizeEqualToSize(_initialSize, CGSizeZero)) {
        _initialSize = self.bounds.size;
    }
    CGSize integerSize = CGSizeMake(_initialSize.width * self.scaleValue, _initialSize.height * self.scaleValue);

    UIFont *adaptiveFont = [UIFont fontWithName:((UIFont *)[textResult.attributes objectForKey:NSFontAttributeName]).fontName size:_initialFont.pointSize * self.scaleValue];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:textResult.attributes];
    [dictionary setObject:adaptiveFont forKey:NSFontAttributeName];
    textResult.attributes = dictionary;
    UIImage *adaptiveImage = [PPHelper drawImageForString:textResult.text attributes:textResult.attributes size:integerSize];
    self.contentView.image = adaptiveImage;
}

#if 0
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    return;
    if (!_render.text) {
        return;
    }
    if (CGSizeEqualToSize(self.currentSize, CGSizeZero)) {
        self.currentSize = self.bounds.size;
    }
    CGSize integerSize = self.currentSize;
    integerSize.width = (int)(integerSize.width + 0.5);
    integerSize.height = (int)(integerSize.height + 0.5);
    
    UIFont *adaptiveFont = [PPHelper findAdaptiveFontWithName:((UIFont *)[_render.attributes objectForKey:NSFontAttributeName]).fontName withText:_render.text forControlSize:integerSize withMinimumSize:2];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:_render.attributes];
    [dictionary setObject:adaptiveFont forKey:NSFontAttributeName];
    _render.attributes = dictionary;
    UIImage *adaptiveImage = [PPHelper drawImageForString:_render.text attributes:_render.attributes size:integerSize];
    self.contentView.image = adaptiveImage;
}
#endif

- (void)loadView {
    UIImageView *contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PPImageEditView class]) owner:self options:nil] objectAtIndex:0];
    [self addSubview:contentView];
    //注视掉，方便调试
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    __weak typeof(self) weakSelf = self;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf);
        make.leading.equalTo(weakSelf);
        make.trailing.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
    }];
    self.contentView = contentView;
}


- (CGRect)intergerizeRect:(CGRect)rect {
    CGPoint point = rect.origin;
    point.x = (int)(point.x + 0.5);
    point.y = (int)(point.y + 0.5);
    
    CGSize size = rect.size;
    size.width = (int)(size.width + 0.5);
    size.height = (int)(size.height + 0.5);
    
    rect.size = size;
    rect.origin = point;
    return rect;
}

- (void)render:(PPRenderResult *)result {
    if (_render) {
        return;
    }
    _render = result;
    self.contentView.image = (UIImage *)result.content;
    self.contentMode = UIViewContentModeScaleToFill;
    if (result.type == PPRenderResultTypeText) {
        _initialFont = [((PPRenderTextResult *)result).attributes objectForKey:NSFontAttributeName];
    }
}


- (IBAction)onImageTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewDidTap:)]) {
        [self.delegate imageEditViewDidTap:self];
    }
}

- (IBAction)onImagePan:(UIPanGestureRecognizer *)sender {
    CGPoint panOffset = [sender translationInView:self.superview];
    self.center = CGPointMake(self.center.x + panOffset.x, self.center.y + panOffset.y);
    [sender setTranslation:CGPointZero inView:self];

    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            if([self.delegate respondsToSelector:@selector(imageEditViewDidDragStart:)]) {
                [self.delegate imageEditViewDidDragStart:self];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if ([self.delegate respondsToSelector:@selector(imageEditViewDidDragMoving:)]) {
                [self.delegate imageEditViewDidDragMoving:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if ([self.delegate respondsToSelector:@selector(imageEditViewDidDragEnd:withPointInWindow:)]) {
                CGPoint point = [sender locationInView:self.window];
                [self.delegate imageEditViewDidDragEnd:self withPointInWindow:point];
            }
        }
            break;
        default:
            break;
    }
}

@end
