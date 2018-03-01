//
//  PPVideoClipView.h
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPVideoEditBaseView.h"
#import "ICGVideoTrimmer.h"

@class PPVideoClipView;
@protocol PPVideoClipViewDelegate<ICGVideoTrimmerDelegate>

- (void)videoClipViewDidCancel:(PPVideoClipView *)clipView;

- (void)videoClipViewDidComplete:(PPVideoClipView *)clipView;

@end


@interface PPVideoClipView : PPVideoEditBaseView

@property (nonatomic, weak) id<PPVideoClipViewDelegate> delegate;

//- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;

- (instancetype)initWithFrame:(CGRect)frame videoAsset:(AVAsset *)asset;

- (void)seekToTime:(CGFloat)time;

- (void)hideTracker:(BOOL)hidden;
@end




