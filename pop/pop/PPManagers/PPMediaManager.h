//
//  SAMediaManager.h
//  SybAssistant
//
//  Created by chance on 14-10-21.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MediaSaveComplition)(NSURL *assetUrl, NSError *error);
typedef void(^MediaFetchComplition)(NSArray *result, NSError *error);
typedef void(^MediaDeleteComplition)(BOOL success,NSError *error);

/** will send in mainThread */
extern NSString * const kSAVideoSaveToAlbumSuccessNotification;

// 图片，视频等多媒体的管理
@interface PPMediaManager : NSObject

+ (PPMediaManager *)sharedManager;

/**
 获取相册视频
 
 @param albumName 相册名称
 @param completion 结果回调, 返回SALocalVideoInfo数组
 */
//- (void)fetchVideosInAblum:(NSString *)albumName completion:(MediaFetchComplition)complition;


/**  
 保存视频到系统媒体库,可自定义文件夹 
 
 @param videoUrlString 要保存的视频文件地址（本地）
 @param albumName 相册名称
 @param completion 结果回调*/
- (void)saveVideo:(NSString *)videoUrlString toAblum:(NSString *)albumName complition:(MediaSaveComplition)compltion;

/**
 *  是否支持删除相册里的资源
 */
- (BOOL)canDeleteVideoInPhotoLibrary;

/**
 *  删除系统相册里的视频资源
 *
 *  @param videoUrls  一个数组，保存要删除视频的url信息(url形式)
 *  @param complition 完成回调
 */
- (void)deleteVideosWithUrls:(NSArray<NSURL *> *)videoUrls complition:(MediaDeleteComplition)complition;
@end
