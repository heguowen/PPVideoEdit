//
//  DSToast.m
//  DSToast
//
//  Created by LS on 8/18/15.
//  Copyright (c) 2015 LS. All rights reserved.
//

#import "PPToast.h"
#import "PPHelper+System.h"

@interface PPToast ()
{
	UIWindow *_window;
	void (^_completeCallback)();
}
@property (nonatomic, assign) CFTimeInterval forwardAnimationDuration;
@property (nonatomic, assign) CFTimeInterval backwardAnimationDuration;
@property (nonatomic, assign) UIEdgeInsets   textInsets;
@property (nonatomic, assign) CGFloat        maxWidth;

- (instancetype)initWithText:(NSString *)text complete:(void (^)())completeCallback;

@end

static CFTimeInterval const kDefaultForwardAnimationDuration = 0.5;
static CFTimeInterval const kDefaultBackwardAnimationDuration = 0.5;
static CFTimeInterval const kDefaultWaitAnimationDuration = 1.5;

static CGFloat const kDefaultTopMargin = 110.0;
static CGFloat const kDefalultTextInset = 10.0;

@implementation PPToast

+ (instancetype)make:(NSString *)text {
    PPToast *toast = [[PPToast alloc] initWithText:text complete:nil];
    return toast;
}

+ (instancetype)make:(NSString *)text complete:(void (^)())completeCallback {
	PPToast *toast = [[PPToast alloc] initWithText:text complete:completeCallback];
	return toast;
}

- (id)initWithText:(NSString *)text complete:(void (^)())completeCallback {
    self = [self initWithFrame:CGRectZero];
    if(self) {
        self.text = text;
		_completeCallback = completeCallback;
        [self sizeToFit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        self.forwardAnimationDuration = kDefaultForwardAnimationDuration;
        self.backwardAnimationDuration = kDefaultBackwardAnimationDuration;
        self.textInsets = UIEdgeInsetsMake(kDefalultTextInset, kDefalultTextInset, kDefalultTextInset, kDefalultTextInset);
        self.maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 20.0;
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentLeft;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:14.0];
    }
    return self;
}

#pragma mark - Show Method
- (void)show {
	[self showWithDuration:kDefaultWaitAnimationDuration];
}

- (void)showWithDuration:(CGFloat)duration {
    [self addAnimationGroupWithWaitDuration:duration];
    CGPoint point = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    point.y = kDefaultTopMargin;
    self.center = point;
	
	_window = [UIWindow new];
	_window.backgroundColor = [UIColor clearColor];
	_window.windowLevel = UIWindowLevelAlert;
	_window.hidden = YES;
	_window.frame = self.frame;
	self.frame = CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.height);
	[_window addSubview:self];
	_window.hidden = NO;
}

#pragma mark - Animation

- (void)addAnimationGroupWithWaitDuration:(CGFloat)waitDuration {
    CABasicAnimation *forwardAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    forwardAnimation.duration = self.forwardAnimationDuration;
    forwardAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5f :1.7f :0.6f :0.85f];
    forwardAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    forwardAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    CABasicAnimation *backwardAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    backwardAnimation.duration = self.backwardAnimationDuration;
    backwardAnimation.beginTime = forwardAnimation.duration + waitDuration;
    backwardAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.15f :0.2f :-0.7f];
    backwardAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    backwardAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[forwardAnimation,backwardAnimation];
    animationGroup.duration = forwardAnimation.duration + backwardAnimation.duration + waitDuration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    animationGroup.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:animationGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
		_window.hidden = YES;
		_window = nil;
        [self removeFromSuperview];
		if (_completeCallback) {
			_completeCallback();
		}
    }
}

#pragma mark - Text Configurate

- (void)sizeToFit {
    [super sizeToFit];
    
    CGRect frame = self.frame;
    CGFloat width = CGRectGetWidth(self.bounds) + self.textInsets.left + self.textInsets.right;
    frame.size.width = width > self.maxWidth? self.maxWidth : width;
    frame.size.height = CGRectGetHeight(self.bounds) + self.textInsets.top + self.textInsets.bottom;
    self.frame = frame;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
//	if ([Helper isGreaterOrEqualToIOS7]) {
		bounds.size = [self.text boundingRectWithSize:CGSizeMake(self.maxWidth - self.textInsets.left - self.textInsets.right,
                                               CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
//	}
//	else {
//		bounds.size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.maxWidth - self.textInsets.left - self.textInsets.right,
//																					 CGFLOAT_MAX)];
//	}
    return bounds;
}

@end
