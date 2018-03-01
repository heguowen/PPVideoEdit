//
//  SADirectoryManager.h
//  GRFoundation
//
//  Created by chance on 14/6/2016.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPUserDefaults.h"

// 文件夹管理器，负责提供各种文件夹地址
@interface PPDirectoryManager : NSObject

+ (instancetype)sharedManager;

/** sdk文件夹，基本上sdk中的本地存储文件都放在这里 
 @note: 文件夹路径 /Documents/GameJoyRecorder 
 */
@property (atomic, readonly) NSString *sdkDirectory;

/** 公共文件夹，负责存放一些与用户无关的数据 
 @note: 文件夹路径 /Documents/GameJoyRecorder/Share
 */
@property (atomic, readonly) NSString *shareDirectory;

/** 日志文件夹，负责存放日志文件
 @note: 文件夹路径 /Library/Caches/GameJoyRecorderLog 
 */
@property (atomic, readonly) NSString *logDirectory;

/** 临时文件夹，用于存放临时文件
 @note: 文件夹路径 /tmp/GameJoyRecorderTemp
 */
@property (atomic, readonly) NSString *tempDirectory;

/** 临时视频文件夹，负责存放视频相关文件
 @note: 文件夹路径 /tmp/GameJoyRecorderTemp/Video
 */
@property (atomic, readonly) NSString *videoDirectory;

/** 临时音频文件夹，负责存放音频相关文件
 @note: 文件夹路径 /tmp/GameJoyRecorderTemp/Audio
 */
@property (atomic, readonly) NSString *tempAudioDirectory;

/** 
 用户文件夹，负责存放用户相关的数据。重要：SDK未登录情况下，返回nil
 @note: 文件夹路径 /Documents/GameJoyRecorder/Users/{UserHashID}/
 */
@property (atomic, readonly) NSString *userDirectory;

// 切换用户目录，如果HashID为空，则userDirectory也会被置为nil
- (void)switchUserDirectoryWithHashID:(NSString *)hashID;


// 清空目录下的所有文件
- (BOOL)cleanDirectory:(NSString *)directoryPath;


@end


@interface PPUserDefaults (UsingSDKDirectory)

/** 公共的UserDefaults */
+ (instancetype)sharedUserDefaults;

/** 当前用户相关的UserDefaults */
+ (instancetype)currentUserDefaults;

/**
 切换当前用户UserDefaults
 @param userDefaultDirectory UserDefaults目录，为空时 [SAUserDefaults currentUserDefaults]返回nil
 */
+ (void)switchCurrentUserDefaultsWithPath:(NSString *)userDefaultDirectory;


@end



