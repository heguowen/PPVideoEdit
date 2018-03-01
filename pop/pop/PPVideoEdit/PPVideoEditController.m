//
//  PPVideoEditController.m
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPVideoEditController.h"
#import "PPVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import "PPRenderSourceView.h"
#import "PPDrawSourceView.h"
#import "PPRenderSourceView.h"
#import "PPMediaManager.h"
#import "PPPermissionManager.h"
#import "PPDirectoryManager.h"
#import "PPToast.h"
#import "PPHelper+Time.h"

#import "PPVideoWatermarkProcess.h"
#import "PPTextSourceView.h"

#import "PPCanvasView.h"
#import "PPVideoClipView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PPVideoEditController ()<PPRenderSourceViewDelegate,PPTextSourceViewDelegate,PPCanvasViewDelegate,PPVideoClipViewDelegate>
{
    AVAsset *_videoAsset;
    NSMutableDictionary<PPVideoEditOptionStr *,PPVideoEditBaseView *> *_videoEditViews;
    PPVideoClipView *_clipView; //考虑去掉该变量

    PPVideoWatermarkProcess *_processor;
//    dispatch_queue_t _playQueue;
    PPRenderTextResult *_currentEditText;
    
    
    CMTime _timeWhenEnterBackground;
}

//play about
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) PPVideoEditOption lastEditOption;

@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat stopTime;
@property (assign, nonatomic) BOOL restartOnPlay;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (weak, nonatomic) IBOutlet PPVideoPlayView *videoPlayView;
@property (weak, nonatomic) IBOutlet UIImageView *VideoFrameImageView;

//UIs
@property (strong, nonatomic) PPCanvasView *canvasView;

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation PPVideoEditController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self doInit];
    [self setupNotifications];
    [self loadCanvasView];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ((playerItem == self.player.currentItem) && ([keyPath isEqualToString:@"status"])){
        if (playerItem.status == AVPlayerItemStatusFailed) {
            NSLog(@"------player item failed:%@",playerItem.error);
        } else if (playerItem.status == AVPlayerStatusReadyToPlay) {
            [self doInitAfterPlayerLoaded];
        }
    }
}

- (void)dealloc {

}

- (void)doInit {
    _videoEditViews = [NSMutableDictionary dictionaryWithCapacity:4];
    _startTime = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)doInitAfterPlayerLoaded {
    _processor = [[PPVideoWatermarkProcess alloc] initWithAsset:_videoAsset];
    _stopTime = [self durationInsec];
//    [self setPlay:YES];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.canvasView removeObserver];
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [self stopPlaybackTimeChecker];
}

- (void)loadViewWithPHAsset:(PHAsset *)asset {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        _videoAsset = asset;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self performSelectorOnMainThread:@selector(setupVideoPlayer) withObject:nil waitUntilDone:YES];
    }];
}


- (void)loadCanvasView {
    if (_canvasView) {
        return;
    }
    
    PPCanvasView *canvasView = [PPCanvasView new];
    [self.view insertSubview:canvasView aboveSubview:_videoPlayView];
    canvasView.delegate = self;
    WS(weakSelf);
    [canvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.leading.equalTo(weakSelf.view.mas_leading);
        make.trailing.equalTo(weakSelf.view.mas_trailing);
    }];
    _canvasView = canvasView;
}

- (void)setupVideoPlayer{
    [self.videoPlayView setPlayer:self.player displayFullScreen:YES];
    self.player = self.videoPlayView.player;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.VideoFrameImageView.image = [self firstFrameWithSize:self.view.size];
    [self setPlay:YES];
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotify:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotify:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotify:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)playerItemDidPlayToEndTimeNotify:(NSNotification *)notification {
    [self seekVideoToPos:self.startTime];
}

- (void)applicationDidBecomeActiveNotify:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (CMTIME_IS_VALID(_timeWhenEnterBackground)) {
            [self.player seekToTime:_timeWhenEnterBackground];
            [self setPlay:YES];
        }
    });
}

- (void)applicationDidEnterBackgroundNotify:(NSNotification *)notification {
    _timeWhenEnterBackground = self.player.currentItem.currentTime;
    [self setPlay:NO];
}


#pragma mark - PPVideoClipViewDelegate
- (void)videoClipViewDidCancel:(PPVideoClipView *)clipView {
    [self hiddenViewWithEditOption:PPVideoEditOptionClip];
    _startTime = 0;
    _stopTime = [self durationInsec];
}

- (void)videoClipViewDidComplete:(PPVideoClipView *)clipView {
    [self hiddenViewWithEditOption:PPVideoEditOptionClip];
}

- (void)trimmerViewDidEndEditing:(ICGVideoTrimmerView *)trimmerView {
    [self setPlay:YES];
}

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime {
    _restartOnPlay = YES;
    [self.player pause];
    self.isPlaying = NO;
    [self stopPlaybackTimeChecker];
//    [self setPlay:NO];
    
//    PPVideoClipView *clipView = (PPVideoClipView *)[_videoEditViews objectForKey:stringWithEditOption(PPVideoEditOptionClip)];

    [_clipView hideTracker:true];
    
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    else{ // right has changed
        [self seekVideoToPos:endTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
}

#pragma mark - PPVideoEditBaseViewProtocol
- (void)editViewWillShow:(PPVideoEditBaseView *)view {
    if (view.useSelfToolBar) {
        self.toolView.hidden = YES;
    }
    self.saveBtn.hidden = YES;
}

- (void)editViewWillHidden:(PPVideoEditBaseView *)view {
    if (view.useSelfToolBar) {
        self.toolView.hidden = NO;
    }
    self.saveBtn.hidden = NO;
}

#pragma mark - PPRenderSourceViewDelegate
- (void)sourceView:(PPRenderSourceView *)view didOutput:(PPRenderResult *)result{
    //如果当前是文本输出,并且不是新建的文本，说明之前的文本可以去掉了
    if ([view isKindOfClass:[PPTextSourceView class]]) {
        PPTextSourceView *textSourceView = (PPTextSourceView *)view;
        if (!textSourceView.isNewText) {
            [_currentEditText changeCurrentState:PPRenderTextStateRemove];
            _currentEditText = nil;
        }
    }
    
    [self.canvasView render:result];
}

#pragma mark - PPTextSourceViewDelegate
- (void)textSourceViewCancelEdit:(PPTextSourceView *)textView {
    [_currentEditText changeCurrentState:PPRenderTextStateShow];
}

#pragma mark - canvasViewDelegate
- (void)canvasView:(PPCanvasView *)canvasView didTapText:(PPRenderTextResult *)textResult {
    [textResult changeCurrentState:PPRenderTextStateEditing];
    
//    [self showViewWithEditOption:PPVideoEditOptionText];
    PPTextSourceView *textSourceView = (PPTextSourceView *)[_videoEditViews objectForKey:stringWithEditOption(PPVideoEditOptionText)];
    textSourceView.originText = textResult.text;
    [textSourceView showSelf];
    self.lastEditOption = PPVideoEditOptionText;
    
    _currentEditText = textResult;
}

- (void)canvasViewBeginEdit:(PPCanvasView *)canvasView {
    self.toolView.hidden = YES;
    self.saveBtn.hidden = YES;
}

- (void)canvasViewEndEdit:(PPCanvasView *)canvasView {
    self.toolView.hidden = NO;
    self.saveBtn.hidden = NO;
}


#pragma mark - clickEvents
- (IBAction)onCloseBtnClick:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"放弃视频?" message:@"如果现在返回，你编辑的视频会丢失。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleCancel handler:nil]];
//    WS(weakSelf);
    [alert addAction:[UIAlertAction actionWithTitle:@"丢失" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeObservers];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)onVideoEditBtnClick:(UIButton *)sender {
    PPVideoEditOption editingOption = sender.tag;
    if (editingOption == self.lastEditOption) {
        [self showViewWithEditOption:self.lastEditOption];
        return;
    }
    
    [self hiddenViewWithEditOption:self.lastEditOption];
    [self showViewWithEditOption:editingOption];
    self.lastEditOption = editingOption;
}

- (IBAction)onSaveBtnClick:(id)sender {
    PPTimeStamp *timeStamp = [PPTimeStamp stampWithStart:self.startTime duration:(self.stopTime - self.startTime)];
    UIImage *snapshotImage = [self.canvasView generateImage];
    [self saveVideoWithClipDuration:timeStamp
                          withImage:snapshotImage
                     withCompletion:^{
    }];
    
}

#pragma mark - private func
- (void)saveVideoWithClipDuration:(PPTimeStamp *)timeStamp
                        withImage:(UIImage *)image
                   withCompletion:(void (^)())completion{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"保存中...";
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:0.1f];

    if (image) {
        _processor.watermark = image;
    }
    [_processor videoOutputWithTimeRange:timeStamp WithCompletion:^(NSURL *url) {
        if (!url) {
            return ;
        }
        [[PPPermissionManager sharedInstance] requestAuthorization:SAAuthorizationTypePhoto result:^(SAAuthorizationStatus status) {
            if (status == SAAuthorizationStatusAuthorized) {
                [[PPMediaManager sharedManager] saveVideo:url.path toAblum:@"相机胶卷" complition:^(NSURL *assetUrl, NSError *error) {
                    if (assetUrl && !error) {
                        [[PPDirectoryManager sharedManager] cleanDirectory:[PPDirectoryManager sharedManager].tempDirectory];
                        [[PPToast make:@"保存成功"] show];
                        NSLog(@"保存成功");
                        if (completion) {
                            completion();
                        }
                    } else {
                        if (completion) {
                            completion();
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                }];
            }
        }];
    }];
}

- (UIImage *)firstFrameWithSize:(CGSize)size {
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.player.currentItem.asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

#pragma mark - view about func
- (void)showViewWithEditOption:(PPVideoEditOption)option {
    //get from cache dictionary
    PPVideoEditBaseView *currentView = [_videoEditViews objectForKey:stringWithEditOption(option)];
    if (currentView) {
        [currentView showSelf];
        return;
    }
    //else,creat new view
    switch (option) {
        case PPVideoEditOptionClip:
        {
        PPVideoClipView *clipView = [[PPVideoClipView alloc] initWithFrame:self.view.frame videoAsset:_videoAsset];
        clipView.delegate = self;
        currentView = clipView;
            _clipView = clipView;
        [self.view addSubview:clipView];
        }
            break;
        case PPVideoEditOptionEmoji:
        case PPVideoEditOptionDraw:
        case PPVideoEditOptionText:
        {
            PPRenderSourceView *renderSourceView = [PPRenderSourceView sourceViewWithSourceType:editOption2SourceType(option)];
            renderSourceView.delegate = self;
            [self setupFullScreenView:renderSourceView toView:self.view];
            currentView = renderSourceView;
        }
            break;
        default:
            break;
    }
    [self.view insertSubview:currentView belowSubview:self.toolView];
    [currentView showSelf];
    [_videoEditViews setObject:currentView forKey:stringWithEditOption(option)];
}

- (void)hiddenViewWithEditOption:(PPVideoEditOption)option {
    PPVideoEditBaseView *videoEditView = [_videoEditViews objectForKey:stringWithEditOption(option)];
    if (videoEditView) {
        [videoEditView hiddenSelf];
    }
}

- (void)setupFullScreenView:(UIView *)view toView:(UIView *)superView {
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:view];
    __weak typeof(superView) weakSuperView = superView;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSuperView);
        make.bottom.equalTo(weakSuperView);
        make.leading.equalTo(weakSuperView);
        make.trailing.equalTo(weakSuperView);
    }];
}


#pragma mark - video about func
- (void)setPlay:(BOOL)play {
    //    PPVideoClipView *clipView = (PPVideoClipView *)[_videoEditViews objectForKey:stringWithEditOption(PPVideoEditOptionClip)];
    //    if (self.isPlaying) { modify 2017 10 23
    if (!play) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [_clipView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [_clipView hideTracker:!self.isPlaying];
}

- (void)seekVideoToPos:(CGFloat)pos {
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)startPlaybackTimeChecker {
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker {
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

- (void)onPlaybackTimeCheckerTimer {
    CMTime curTime = [self.player currentTime];
    Float64 seconds = CMTimeGetSeconds(curTime);
    if (seconds < 0){
        seconds = 0; // this happens! dont know why.
    }
    self.videoPlaybackPosition = seconds;
    
//    PPVideoClipView *clipView = (PPVideoClipView *)[_videoEditViews objectForKey:stringWithEditOption(PPVideoEditOptionClip)];
    [_clipView seekToTime:seconds];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [_clipView seekToTime:self.startTime];
    }
}

- (Float64)durationInsec {
    AVURLAsset *asset = (AVURLAsset *)_videoAsset;
    
    NSTimeInterval durationInSeconds = 0.0;
    if (asset){
        durationInSeconds = CMTimeGetSeconds(asset.duration);
    }
    return durationInSeconds;
}

@end
