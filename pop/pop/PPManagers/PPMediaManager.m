//
//  SAMediaManager.m
//  SybAssistant
//
//  Created by chance on 14-10-21.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PPMediaManager.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetResource.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHAssetChangeRequest.h>
#import <Photos/PHAssetCollectionChangeRequest.h>

// 这个通知是解决：自由录制浮圈开着上传视频的时候，视频列表处于展示状态，当自由录制浮圈显示上传完成时，视频列表应该更新。
NSString * const kSAVideoSaveToAlbumSuccessNotification = @"kSAVideoSaveToAlbumSuccessNotification";


@interface PPMediaManager()<UIAlertViewDelegate> {
    ALAssetsLibrary *_assetsLibrary;
    void (^ _selectedBlock)(NSInteger selectedIndex);
}

@end

@implementation PPMediaManager

+ (PPMediaManager *)sharedManager {
    static PPMediaManager *manager = nil;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[PPMediaManager alloc] init];
        });
    }
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _assetsLibrary = [ALAssetsLibrary new];
    }
    return self;
}

// 获取相册视频个数
- (void)fetchVideoCountInAblum:(NSString *)albumName completion:(void(^)(NSUInteger count))complition {
    // 查找媒体文件夹
    __block NSUInteger videoCount = 0;
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]) {
            videoCount = [group numberOfAssets];
            *stop = YES;
        }
        if (!group) {
            complition(videoCount);
        }
        
    } failureBlock:^(NSError *error) {
        complition(0);
    }];
}


- (void)onFetchComplition:(MediaFetchComplition)complition
                   result:(NSArray *)result
                    error:(NSError *)error {
    if (complition) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complition(result, error);
        });
    }
}


// 保存图片
- (void)saveImage:(UIImage *)image toAblum:(NSString *)albumName completion:(MediaSaveComplition)complition {
    [_assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) { // 保存失败
            complition(assetURL, error);
            return;
        }
        
        if (assetURL && albumName) {
            [self addAsset:assetURL toAblum:albumName complition:^(NSError *error) {
                complition(assetURL, error);
            }];
        }
    }];
}


// 保存视频
- (void)saveVideo:(NSString *)videoUrlString toAblum:(NSString *)albumName complition:(MediaSaveComplition)complition {
    NSURL *videoUrl = [NSURL URLWithString:videoUrlString];
    NSLog(@"Save To Media Library: %@", videoUrl);
//    ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
    BOOL canSave = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrlString);
    if (!canSave) {
        if (complition) {
            NSError *error = [NSError errorWithDomain:@"com.tencent.GameJoyRecorder"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"Can not save video"}];
            complition(nil, error);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [_assetsLibrary writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) { // 保存失败
            complition(assetURL, error);
            return;
        }
        
        // add video verification
//        [[SALocalVideoVerifier defaultVerifier] addVerificationForVideoAtPath:videoUrlString];
        
        if (assetURL && albumName) {
            [weakSelf addAsset:assetURL toAblum:albumName complition:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSAVideoSaveToAlbumSuccessNotification object:nil];
                });
                complition(assetURL, error);
            }];
            
        } else {
            complition(assetURL, nil);
        }
    }];
}


// 把媒体文件归类到自定义文件夹下
- (void)addAsset:(NSURL *)assetUrl
         toAblum:(NSString *)albumName
      complition:(ALAssetsLibraryAccessFailureBlock)complition {
    __block BOOL hasFoundAlbum = NO;
    
    // 查找媒体文件夹
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]) {
            hasFoundAlbum = YES;
            // 找到文件夹后把文件归类到该文件夹下面
            [_assetsLibrary assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];
                complition(nil);
            } failureBlock:complition];
        }
        
    } failureBlock:complition];
    
    // 1s后判读是否已经插入数据，没有的话创建文件夹后把文件归类到该文件夹下面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (hasFoundAlbum) {
            return;
        }
        
        ALAssetsLibrary *libraryRef = _assetsLibrary;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [libraryRef enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if ([albumName isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]){
                        // 找到文件夹后把文件归类到该文件夹下面
                        [_assetsLibrary assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
                            [group addAsset:asset];
                            complition(nil);
                        } failureBlock:complition];
                    }
                } failureBlock:^(NSError *error) {
                    complition(error);
                }];
            } else {
                if (error) {
                    NSLog(@"Error creating album: %@", error);
                    complition(error);
                }
            }
        }];
    });
}

- (BOOL)canDeleteVideoInPhotoLibrary {
    Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
    return (PHPhotoLibrary_class != nil);
}

- (void)deleteVideosWithUrlStrings:(NSArray<NSString *> *)videoUrlStrings complition:(MediaDeleteComplition)complition {
    if (![self canDeleteVideoInPhotoLibrary]) {
        complition(NO,[NSError errorWithDomain:@"VideoDelete" code:-1 userInfo:@{@"info":@"only >=ios8 support delete video"}]);
        NSLog(@"only >= ios8 support delete video");
    }
    NSMutableArray<NSURL *> *videoUrls = [NSMutableArray arrayWithCapacity:videoUrlStrings.count];
    for (NSString *urlString in videoUrlStrings) {
        [videoUrls addObject:[NSURL URLWithString:urlString]];
    }
    [self deleteVideosWithUrls:videoUrls complition:^(BOOL success, NSError *error) {
        if (complition) {
            complition(success,error);
        }
    }];
}

- (void)deleteVideosWithUrls:(NSArray<NSURL *> *)videoUrls complition:(MediaDeleteComplition)complition {
    if (![self canDeleteVideoInPhotoLibrary]) {
        complition(NO,[NSError errorWithDomain:@"VideoDelete" code:-1 userInfo:@{@"info":@"only >=ios8 support delete video"}]);
        NSLog(@"only >= ios8 support delete video");
    }
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:videoUrls options:nil];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:fetchResult];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (complition) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complition(success,error);
            });
        }
    }];
}

@end



