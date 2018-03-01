//
//  PPVideoPlayView.h
//  pop
//
//  Created by neil on 2017/9/12.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;

@interface PPVideoPlayView : UIView
@property (nonatomic, strong, readonly) AVPlayer* player;

- (void)setPlayer:(AVPlayer *)player displayFullScreen:(BOOL)fullScreen;
//- (void)setVideoFillMode:(NSString *)fillMode;

@end
