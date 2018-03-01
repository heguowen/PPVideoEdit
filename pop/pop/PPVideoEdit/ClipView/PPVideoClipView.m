//
//  PPVideoClipView.m
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//

#define kVideoTrimmerViewHeight 65
#import "PPVideoClipView.h"
//#import "ICGVideoTrimmer.h"

@interface PPVideoClipView ()<ICGVideoTrimmerDelegate>
{
//    NSURL *_videoUrl;
    AVAsset *_videoAsset;
    __weak id<PPVideoClipViewDelegate> _delegate;
    BOOL _firstTimeLayoutSubview;
}
@property (nonatomic, strong) ICGVideoTrimmerView *trimmerView;

@end

@implementation PPVideoClipView

@dynamic delegate;

//- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl {
//    if (self = [super initWithFrame:frame]) {
//        _firstTimeLayoutSubview = YES;
//        _videoUrl = videoUrl;
//        [self setupToolBar];
//        [self loadVideoTrimmerView];
//    }
//    return self;
//}
- (instancetype)initWithFrame:(CGRect)frame videoAsset:(AVAsset *)asset {
    if (self = [super initWithFrame:frame]) {
        _firstTimeLayoutSubview = YES;
//        _videoUrl = videoUrl;
        _videoAsset = asset;
        [self setupToolBar];
        [self loadVideoTrimmerView];
    }
    return self;
}


//- (void)layoutSubviews {
//    [super layoutSubviews];
//    if (_firstTimeLayoutSubview) {
//
//        _firstTimeLayoutSubview = NO;
//        [self.trimmerView notifyDelegateOfDidChange];
////        [self.trimmerView resetSubviews];
//    }
//}

#pragma mark - API
- (void)seekToTime:(CGFloat)time{
    [self.trimmerView seekToTime:time];
}

- (void)hideTracker:(BOOL)hidden {
    [self.trimmerView hideTracker:hidden];
}

#pragma mark - EDitBaseView Func
- (BOOL)useSelfToolBar {
    return YES;
}

- (void)showSelf {
    [super showSelf];
    
    [self.trimmerView positionNeedUpdate];
}

- (void)hiddenSelf {
    [super hiddenSelf];

}

#pragma mark - load views
- (void)setupToolBar {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:cancelBtn];
    cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weakSelf = self;
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf).offset(20);
        make.top.equalTo(weakSelf).offset(10);
    }];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [cancelBtn addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:completeBtn];
    completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(weakSelf).offset(-20);
        make.top.equalTo(weakSelf).offset(10);
    }];
    [completeBtn setTitle:@"确定" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(onCompleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadVideoTrimmerView {
    AVAsset *asset = _videoAsset;
    ICGVideoTrimmerView *trimmerView = [[ICGVideoTrimmerView alloc] initWithFrame:CGRectMake(0, self.height - kVideoTrimmerViewHeight - 21, self.width, kVideoTrimmerViewHeight) asset:asset];
    [trimmerView setThemeColor:[UIColor blackColor]];
//    [trimmerView setAsset:self.asset];
    [trimmerView setShowsRulerView:YES];
    [trimmerView setRulerLabelInterval:10];
    [trimmerView setTrackerColor:[UIColor cyanColor]];
    [trimmerView setDelegate:self];

    [self addSubview:trimmerView];
    self.trimmerView = trimmerView;
//    [self.trimmerView resetSubviews];
}

#pragma mark - event handle
- (void)onCancelBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(videoClipViewDidCancel:)]) {
        [self.delegate videoClipViewDidCancel:self];
    }
}

- (void)onCompleteBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(videoClipViewDidComplete:)]) {
        [self.delegate videoClipViewDidComplete:self];
    }
}

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime {
    if ([self.delegate respondsToSelector:@selector(trimmerView:didChangeLeftPosition:rightPosition:)]) {
        [self.delegate trimmerView:trimmerView didChangeLeftPosition:startTime rightPosition:endTime];
    }
}

- (void)trimmerViewDidEndEditing:(ICGVideoTrimmerView *)trimmerView {
    if ([self.delegate respondsToSelector:@selector(trimmerViewDidEndEditing:)]) {
        [self.delegate trimmerViewDidEndEditing:trimmerView];
    }
}

- (id<PPVideoClipViewDelegate>)delegate{
    return _delegate;
}

- (void)setDelegate:(id<PPVideoClipViewDelegate>)delegate {
    _delegate = delegate;
}

@end
