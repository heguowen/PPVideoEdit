//
//  PPTextImageView.m
//  pop
//
//  Created by neil on 2017/9/13.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPTextSourceView.h"
#import "PPHelper+Draw.h"
#import "PPRenderTextResult.h"

@interface PPTextSourceView()
{
    UIView *_canvasView;
    UIView *_contentView;
    MASConstraint *_heightConstraint;
    id<PPTextSourceViewDelegate> _delegate;
    
     BOOL _keyboardShowHaveHandle;
}
//@property (atomic)

@property (nonatomic, assign, readwrite) BOOL isNewText;

@property (weak, nonatomic) IBOutlet UITextView *textView;

//constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textviewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;


@end


@implementation PPTextSourceView

@dynamic delegate;

#pragma mark - init func
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    [self setupNotify];
    [self loadContentView];
    [self boldFontForTextView:self.textView];
}


- (void)setupNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)boldFontForTextView:(UITextView *)textView {
    UIFont *currentFont = textView.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    textView.font = newFont;
}

- (void)loadContentView {
    if (!_contentView) {
        UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PPTextSourceView class]) owner:self options:nil] firstObject];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentView];
        
        __weak typeof(self) weakSelf = self;
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf);
            make.left.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf);
        }];
        
        _contentView = contentView;
    }
}


#pragma mark - API
- (void)showSelf {
    [super showSelf];
    [self.textView becomeFirstResponder];
    self.textView.text = self.originText;
}

- (void)hiddenSelf {
    [self outputResult:self.textView.text];

    [super hiddenSelf];
    
    self.textView.text = nil;
    self.originText = nil;
    [self.textView resignFirstResponder];

    _contentView.alpha = 0.0f;
    _contentView.hidden = YES;
}

- (BOOL)useSelfToolBar {    
    return YES;
}

#pragma mark - eventhandle

- (IBAction)onCompleteBtnClick:(id)sender {
    [self.textView resignFirstResponder];
//    [self hiddenSelf];
}
- (IBAction)onBackgroundViewClick:(id)sender {
    [self hiddenSelf];
}

#pragma mark---------------UITextViewDelegate-------------
- (void)textViewDidChange:(UITextView *)textView
{
    textView.scrollEnabled = NO;
    static CGFloat maxHeight =80.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<frame.size.height) {
        frame.origin.y = frame.origin.y + (frame.size.height - size.height);
        textView.frame = CGRectMake(frame.origin.x, textView.y, frame.size.width, size.height);
    }
    else if(size.height>frame.size.height){
        if (size.height >= maxHeight)
        {
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
        }
        else
        {
            frame.origin.y = frame.origin.y - (size.height - frame.size.height);
            textView.scrollEnabled = NO;    // 不允许滚动
        }
        textView.frame = CGRectMake(frame.origin.x, textView.y, frame.size.width, size.height);
    }
    _textviewHeightConstraint.constant = size.height;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    self.backgroundViewHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - keyboardFrame.size.height;
    [self setNeedsLayout];
    
    if (!_contentView.hidden) {
        return;
    }
    
    if (_keyboardShowHaveHandle) {
        return;
    }
    _keyboardShowHaveHandle = YES;
    _contentView.alpha = 0.0f;
    [UIView animateWithDuration:animationDuration animations:^{
        _contentView.alpha = 1.0f;
        _contentView.hidden = NO;
        _keyboardShowHaveHandle = NO;
    }];
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    [self hiddenSelf];
}

- (void)outputResult:(NSString *)text{
    if (![self.delegate respondsToSelector:@selector(sourceView:didOutput:)]) {
        return;
    }
    //说明文本没改过
    if ([text isEqualToString:self.originText]) {
        [self.delegate textSourceViewCancelEdit:self];
        return;
    }
    
    if (!text) {
        [self.delegate sourceView:self didOutput:nil];
        return;
    }
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:self.textView.textColor,
                                 NSFontAttributeName: self.textView.font
                                 };
    CGRect textRect = [self frameOfTextRange:NSMakeRange(0, self.textView.text.length)];

    
    UIImage *textImage = [PPHelper drawImageForString:text attributes:attributes size:textRect.size];
    PPRenderTextResult *result = (PPRenderTextResult *)[PPRenderResult renderResultWithType:PPRenderResultTypeText];
    result.content = textImage;
    result.frame = textRect;
    result.text = text;
    result.attributes = attributes;
    self.isNewText = (self.originText == nil) ? YES : NO;
    
    [self.delegate sourceView:self didOutput:result];
}

#pragma mark - private func
- (CGRect)frameOfTextRange:(NSRange)range {
    // firstRectForRange方法计算的文本高度总是少一行，所以这里采取折中的方式
    UITextView *textView = _textView;
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition: start toPosition: end];
    
    //text height
    NSArray *selectionRects = [textView selectionRectsForRange: textRange];
    CGRect heightRect = CGRectZero;
    for (UITextSelectionRect *selectionRect in selectionRects)
    {
        heightRect = CGRectUnion(heightRect, selectionRect.rect);
    }
    heightRect = [self convertRect:heightRect fromView:textView.textInputView];
    
    //text origin and width
    CGRect widthRect = [textView firstRectForRange:textRange];
    widthRect = [self convertRect:widthRect fromView:textView.textInputView];
    
    CGRect resultRect = widthRect;
    resultRect.size.height = heightRect.size.height;
    return resultRect;
}

- (void)setDelegate:(id<PPTextSourceViewDelegate>)delegate {
    _delegate = delegate;
}

- (id<PPTextSourceViewDelegate>)delegate {
    return _delegate;
}


@end
