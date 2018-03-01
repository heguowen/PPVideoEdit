//
//  PPVideoBaseProcess.m
//  pop
//
//  Created by neil on 2017/10/10.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPVideoBaseProcess.h"
#import "PPVideoEditDefines.h"
#import "PPHelper+Time.h"
#import "PPDirectoryManager.h"
#import "PPAVAssetExportSession.h"

@interface PPVideoBaseProcess()
{
    AVAsset *_videoAsset;
}
@end

@implementation PPVideoBaseProcess

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        _videoAsset = asset;
    }
    return self;
}
- (instancetype)initWithURL:(NSURL *)url {
    AVURLAsset *source = [AVURLAsset URLAssetWithURL:url options:nil];
    return [self initWithAsset:source];
}


- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size {
    //must be implement by subclass;
}
- (void)videoOutputWithTimeRange:(PPTimeStamp *)timeStamp
                  WithCompletion:(void (^)(NSURL *url))completion;{
    // 1 - Early exit if there's no video file selected
    if (!self.videoAsset) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Load a Video Asset First"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = nil;
    AVMutableCompositionTrack *compositionAudioTrack = nil;
    
    NSArray<AVAssetTrack *> *videoTracks = [_videoAsset tracksWithMediaType:AVMediaTypeVideo];
    NSArray<AVAssetTrack *> *audioTracks = [_videoAsset tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetTrack *videoTrack = nil;
    AVAssetTrack *audioTrack = nil;
    
    CMTimeRange timeRange = [self cmtimeRangeFromTimestamp:timeStamp];
    
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
//        hasVideoTrack = YES;
    }
    
    if (!hasVideoTrack) {
        completion(nil);
        return;
    }
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation =  UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation = UIImageOrientationDown;
    }
//    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if (isVideoAssetPortrait) {
        //如果是竖屏
        naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [videolayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    } else {
        //处理横屏
        naturalSize = videoTrack.naturalSize;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        screenSize.width = [self integralMutipleOf16:screenSize.width];
        screenSize.height = [self integralMutipleOf16:screenSize.height];
        
        CGFloat scaleValue = screenSize.height/naturalSize.height;
        CGSize scaleSize = CGSizeMake(naturalSize.width * scaleValue, naturalSize.height * scaleValue);
        CGPoint topLeft = CGPointMake(screenSize.width * 0.5 - scaleSize.width * 0.5, screenSize.height * 0.5 - scaleSize.height * 0.5);
        naturalSize = screenSize;
        CGAffineTransform originTransform = videoTrack.preferredTransform;
        
        CGAffineTransform resultTransform = CGAffineTransformConcat(CGAffineTransformScale(originTransform, scaleValue, scaleValue), CGAffineTransformMakeTranslation(topLeft.x, topLeft.y));
        [videolayerInstruction setTransform:resultTransform atTime:kCMTimeZero];
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 4 - Get path

    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self outputPath]];
    
    // 5 - Create exporter
    //这里使用必须使用第三方库PPAVAssetExportSession,不然的话，导出的视频avplayer播放不了
    PPAVAssetExportSession *exporter = [[PPAVAssetExportSession alloc] initWithAsset:composition];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    exporter.timeRange = timeRange;
    
    exporter.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @(naturalSize.width),
    AVVideoHeightKey: @(naturalSize.height),
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @6000000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    exporter.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(exporter.outputURL);
            }
        });
    }];
}

#pragma mark - helper func
- (CMTimeRange)cmtimeRangeFromTimestamp:(PPTimeStamp *)timeStamp {
    CMTime start = CMTimeMakeWithSeconds(timeStamp.start, kCMTimeScale);
    CMTime duration = CMTimeMakeWithSeconds(timeStamp.duration, kCMTimeScale);
    CMTimeRange timeRange = CMTimeRangeMake(start, duration);
    return timeRange;
}

- (NSString *)outputPath {
    NSInteger secondsFrom1970 = [PPHelper timeNow];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",@(secondsFrom1970)];
    NSString *filePath = [[PPDirectoryManager sharedManager].tempDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

/**
 按照视频理论，存储的视频宽高都必须是16的整数倍，这样macro block 才能进行处理
 @param originalInteger 原始宽度或者高度
 @return 16整数倍的数
 */
- (NSInteger)integralMutipleOf16:(NSInteger)originalInteger {
    NSInteger remainder = originalInteger % 16;
    NSInteger result = originalInteger - remainder + 16;
//    if (remainder > 8) {
//        result += 16;
//    }
    return result;
}
@end
