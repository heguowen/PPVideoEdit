//
//  PPVideoPlayView.m
//  pop
//
//  Created by neil on 2017/9/12.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
//#import "PPHelper+System.h"

@interface PPVideoPlayView()
//{
//     AVPlayer *_player;
//}
@end

@implementation PPVideoPlayView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

//- (void)dealloc {
//    
//}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player displayFullScreen:(BOOL)fullScreen
{
    if (!fullScreen) {
        [(AVPlayerLayer*)[self layer] setPlayer:player];
        return;
    }
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVURLAsset *source = (AVURLAsset *)player.currentItem.asset;
    AVMutableCompositionTrack *compositionVideoTrack = nil;
    AVMutableCompositionTrack *compositionAudioTrack = nil;
    
    NSArray<AVAssetTrack *> *videoTracks = [source tracksWithMediaType:AVMediaTypeVideo];
    NSArray<AVAssetTrack *> *audioTracks = [source tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetTrack *videoTrack = nil;
    AVAssetTrack *audioTrack = nil;
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, source.duration); //[self cmtimeRangeFromTimestamp:timeStamp];
    
    BOOL hasVideoTrack = NO;
    if (videoTracks.count > 0) {
        compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        videoTrack = [videoTracks firstObject];
        [compositionVideoTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:timeRange.start error:nil];
        hasVideoTrack = YES;
    }
    
    if (audioTracks.count > 0) {
        compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        audioTrack = [audioTracks firstObject];
        [compositionAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:timeRange.start error:nil];
    }
    
    if (!hasVideoTrack) {
        return;
    }
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    
    //  - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    UIImageOrientation videoAssetOrientation  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait  = NO;
    CGAffineTransform videoTransform = videoTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//        videoAssetOrientation =  UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//        videoAssetOrientation =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//        videoAssetOrientation = UIImageOrientationDown;
    }
//    [videolayerInstruction setCropRectangle:[UIScreen mainScreen].bounds atTime:kCMTimeZero];
    CGSize naturalSize;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    if (isVideoAssetPortrait) {
        //如果是竖屏
        naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
//        if ((naturalSize.width/2.0 > screenSize.width) && (naturalSize.height/2.0 > screenSize.height)) {
//            naturalSize = CGSizeMake(naturalSize.width/2.0, naturalSize.height/2.0);
//        }
//        CGAffineTransform resultTransform = CGAffineTransformTranslate(videoTrack.preferredTransform, 0.5, 0.5);
        [videolayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    } else {
        //对横屏进行放缩处理
        naturalSize = videoTrack.naturalSize;
        CGFloat scaleValue = screenSize.height/naturalSize.height;
        CGSize scaleSize = CGSizeMake(naturalSize.width * scaleValue, naturalSize.height * scaleValue);
        CGPoint topLeft = CGPointMake(screenSize.width * 0.5 - scaleSize.width * 0.5, screenSize.height * 0.5 - scaleSize.height * 0.5);
        naturalSize = screenSize;
        CGAffineTransform originTransform = videoTrack.preferredTransform;
        
        CGAffineTransform resultTransform = CGAffineTransformConcat(CGAffineTransformScale(originTransform, scaleValue, scaleValue), CGAffineTransformMakeTranslation(topLeft.x, topLeft.y));
        [videolayerInstruction setTransform:resultTransform atTime:kCMTimeZero];
    }
    
    [videolayerInstruction setOpacity:0.0 atTime:source.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.renderSize = naturalSize;
    mainComposition.instructions = @[mainInstruction];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:composition];
    playItem.videoComposition = mainComposition;
    AVPlayer *newPlayer = [AVPlayer playerWithPlayerItem:playItem];
    [(AVPlayerLayer*)[self layer] setPlayer:newPlayer];
}

//- (void)setVideoFillMode:(NSString *)fillMode
//{
//    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
//    playerLayer.pixelBufferAttributes = @{};
//    playerLayer.videoGravity = fillMode;
//}


@end
