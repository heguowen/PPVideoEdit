//
//  PPEmojiView.m
//  pop
//
//  Created by neil on 2017/9/12.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPEmojiSourceView.h"
#import "PPEmojiCell.h"
#import "UIView+FrameMethods.h"
#import "PPRenderResultDefines.h"

const CGFloat kBaseContentViewHeight = 275;

typedef NS_ENUM(NSInteger,PPEmojiSourceViewPosition) {
    PPEmojiSourceViewPositionMiddle  = 0,
    PPEmojiSourceViewPositionTop     = 1,
    PPEmojiSourceViewPositionBottom  = 2,
};

@interface PPEmojiSourceView ()<UICollectionViewDelegate,UICollectionViewDataSource,
                                 UIGestureRecognizerDelegate>
{
    id _delegate;
    NSArray<UIImage *> *_emojis;
    CGFloat _originHeaderHeight;
    
    CGFloat _prevHeight;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

//当contentHeightConstraint为0时，如果不将header高度置0，会有警告
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;

@property (assign, nonatomic) PPEmojiSourceViewPosition emojiPosition;

//gesture
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *downSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *upSwipGesture;

@end

@implementation PPEmojiSourceView


- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadDatas];
    [self.collectionView reloadData];
    self.emojiPosition = PPEmojiSourceViewPositionMiddle;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    [self loadView];
    [self loadDatas];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PPEmojiCell" bundle:nil] forCellWithReuseIdentifier:@"PPEmojiCell"];
    _originHeaderHeight = self.headerHeightConstraint.constant;
    _prevHeight = kBaseContentViewHeight;
//    [self.panGesture requireGestureRecognizerToFail:self.downSwipeGesture];
//    [self.panGesture requireGestureRecognizerToFail:self.upSwipGesture];
}

- (void)loadView {
    UIView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"PPEmojiSourceView" owner:self options:nil] objectAtIndex:0];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    __weak typeof(self) weakSelf = self;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
        make.leading.equalTo(weakSelf);
        make.trailing.equalTo(weakSelf);
    }];
}


- (void)loadDatas {
    if (_emojis.count > 0) {
        return;
    }
    NSMutableArray *emojis = [NSMutableArray arrayWithCapacity:108];
    for (int i = 1; i <= 98; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%.2d",i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [emojis addObject:image];
        }
    }
    _emojis = emojis;
}



#pragma mark - API
- (void)showSelf {
    [super showSelf];
    
    [self.collectionView reloadData];
//    self.collectionView.hidden = NO;
    //重新显示的时候，初始化为初始高度
    [self scrollViewToPos:PPEmojiSourceViewPositionMiddle animate:NO];
//    self.contentHeightConstraint.constant = kBaseContentViewHeight;
//    [self layoutIfNeeded];
}

- (void)hiddenSelf {
    [super hiddenSelf];
//    self.contentHeightConstraint.constant = 0;
//    [self layoutIfNeeded];
//
//    self.collectionView.hidden = YES;
}

- (BOOL)useSelfToolBar {
    return YES;
}

#pragma mark - collectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  _emojis.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PPEmojiCell *emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PPEmojiCell class]) forIndexPath:indexPath];
    [emojiCell feedData:[_emojis objectAtIndex:indexPath.row]];
    return emojiCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat centerX = CGRectGetMidX(self.frame); //CGRectGetWidth(self.frame) / 2.0f;
    CGFloat centerY = CGRectGetMidY(self.frame); //(CGRectGetHeight(self.frame) - CGRectGetHeight(self.collectionView.frame)) / 2.0f;
    
    
    UIImage *currentImage = [_emojis objectAtIndex:indexPath.row];
    
    CGFloat imageWidth = currentImage.size.width;
    CGFloat imageHeight = currentImage.size.height;
    
    CGRect rect = CGRectMake(centerX - imageWidth/2, centerY - imageHeight/2, imageWidth, imageHeight);
    
    if ([self.delegate respondsToSelector:@selector(sourceView:didOutput:)]) {
        PPRenderResult *result = [PPRenderResult renderResultWithType:PPRenderResultTypeEmoji]; //[PPRenderImageResult new];
//        result.type = PPRenderResultTypeImageOnly;
        result.content = currentImage;
        result.frame = rect;
        [self.delegate sourceView:self didOutput:result];
    }
    [self hiddenSelf];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y < -100) && (self.emojiPosition == PPEmojiSourceViewPositionTop)) {
        [self scrollViewToPos:PPEmojiSourceViewPositionBottom animate:YES];
    }
}

#pragma mark - event handle

- (IBAction)onHeaderViewPan:(id)sender {
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [gesture translationInView:self];
    
    CGFloat resultHeight = self.contentHeightConstraint.constant - translation.y;
    self.contentHeightConstraint.constant = resultHeight;
    [self layoutIfNeeded];
    [gesture setTranslation:CGPointZero inView:self];
    NSLog(@"resultHeight is %f",resultHeight);
    if (gesture.state == UIGestureRecognizerStateEnded) {
        PPEmojiSourceViewPosition position = [self positionFromFrameY:self.contentHeightConstraint.constant withPrevY:_prevHeight]; //[self positionFromFrameY:self.contentHeightConstraint.constant];
        [self scrollViewToPos:position animate:YES];
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(assignPrevHeight:) object:nil];
    [self performSelector:@selector(assignPrevHeight:) withObject:@(resultHeight) afterDelay:0.2];
//    _prevHeight = resultHeight;
    NSLog(@"prevHeight is %f",_prevHeight);
}

- (void)assignPrevHeight:(NSNumber *)heightObject {
    _prevHeight = heightObject.floatValue;
}

- (IBAction)onHeaderViewSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionUp) {
        if (self.emojiPosition == PPEmojiSourceViewPositionMiddle) {
            [self scrollViewToPos:PPEmojiSourceViewPositionTop animate:YES];
        }
    } else if (sender.direction == UISwipeGestureRecognizerDirectionDown) {
        if (self.emojiPosition == PPEmojiSourceViewPositionTop) {
            [self scrollViewToPos:PPEmojiSourceViewPositionMiddle animate:YES];
        } else if (self.emojiPosition == PPEmojiSourceViewPositionMiddle) {
            [self scrollViewToPos:PPEmojiSourceViewPositionBottom animate:YES];
        } else {
            NSLog(@"needn‘t scroll");
        }
    } else {
        return;
    }
}

- (IBAction)onBlankAreaClick:(id)sender {
    if (self.contentHeightConstraint.constant > 0) {
        [self hiddenSelf];
    }
}

- (void)scrollViewToPos:(PPEmojiSourceViewPosition)position animate:(BOOL)animate {
    self.emojiPosition = position;
    CGFloat height = [self heightFromPosition:position];
    if (height > 0) {
        self.headerHeightConstraint.constant = _originHeaderHeight;
    } else {
        self.headerHeightConstraint.constant = 0;
    }
    
    if (!animate) {
        self.contentHeightConstraint.constant = height;
        [self layoutIfNeeded];
        return;
    }
    
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentHeightConstraint.constant = height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished&&position == PPEmojiSourceViewPositionBottom) {
            [self hiddenSelf];
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.contentView]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

#pragma mark - y value to PPEmojiSourceViewPosition
//根据位置来判断上还是下的算法
- (PPEmojiSourceViewPosition)positionFromFrameY:(CGFloat)y {
    PPEmojiSourceViewPosition position;
    if (y < kBaseContentViewHeight) {
        if (y < kBaseContentViewHeight / 2.0f) {
            position = PPEmojiSourceViewPositionBottom;
        } else {
            position = PPEmojiSourceViewPositionMiddle;
        }
    } else {
        if (y < (kBaseContentViewHeight + self.height)/2.0f) {
            position = PPEmojiSourceViewPositionMiddle;
        } else {
            position = PPEmojiSourceViewPositionTop;
        }
    }
    return position;
}
//根据手势最终方向来判断上还是下的算法
- (PPEmojiSourceViewPosition)positionFromFrameY:(CGFloat)y  withPrevY:(CGFloat)prevY{
    BOOL moveUp;
    if (prevY < y) {
        moveUp = YES;
    } else {
        moveUp = NO;
    }
    PPEmojiSourceViewPosition resultPosition;
    switch (self.emojiPosition) {
        case PPEmojiSourceViewPositionTop:
        {
            if (moveUp) {
                resultPosition = PPEmojiSourceViewPositionTop;
            } else {
                resultPosition = PPEmojiSourceViewPositionMiddle;
            }
        }
            break;
        case PPEmojiSourceViewPositionMiddle:
        {
            if (moveUp) {
                if (y > kBaseContentViewHeight) {
                    resultPosition = PPEmojiSourceViewPositionTop;
                } else {
                    resultPosition = PPEmojiSourceViewPositionMiddle;
                }
            } else {
                if (y > kBaseContentViewHeight) {
                    resultPosition = PPEmojiSourceViewPositionMiddle;
                } else {
                    resultPosition = PPEmojiSourceViewPositionBottom;
                }
            }
        }
            break;
        case PPEmojiSourceViewPositionBottom:
        {
            if (moveUp) {
                resultPosition = PPEmojiSourceViewPositionMiddle;
            } else {
                resultPosition = PPEmojiSourceViewPositionBottom;
            }
        }
            break;
        default:
            break;
    }
    return resultPosition;
}

- (CGFloat)heightFromPosition:(PPEmojiSourceViewPosition)position{
    CGFloat height = 0;
    switch (position) {
        case PPEmojiSourceViewPositionBottom:
            height = 0;
            break;
        case PPEmojiSourceViewPositionMiddle:
            height = kBaseContentViewHeight;
            break;
        case PPEmojiSourceViewPositionTop:
            height = self.height;
            break;
        default:
            break;
    }
    return height;
}


@end
