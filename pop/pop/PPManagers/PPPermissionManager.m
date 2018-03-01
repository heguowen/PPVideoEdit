//
//  SAPermissionManager.m
//  GRFoundation
//
//  Created by neil on 16/11/21.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "PPPermissionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

@interface PPPermissionManager ()<UIAlertViewDelegate>
{
    void (^ _selectedBlock)(NSInteger selectedIndex);
}
@end

@implementation PPPermissionManager

+ (instancetype)sharedInstance {
    static PPPermissionManager *sharedManager = nil;
    if (!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!sharedManager) {
                sharedManager = [PPPermissionManager new];
            }
        });
    }
    return sharedManager;
}


- (SAAuthorizationStatus)authorizationStatusWithType:(SAAuthorizationType)authorizationType{
    if (authorizationType == SAAuthorizationTypeAudio) {
        AVAudioSessionRecordPermission audioPermission = [[AVAudioSession sharedInstance] recordPermission];
        if (audioPermission == AVAudioSessionRecordPermissionUndetermined) {
            return SAAuthorizationStatusNotDetermined;
        }else if (audioPermission == AVAudioSessionRecordPermissionDenied) {
            return SAAuthorizationStatusDenied;
        } else if (audioPermission == AVAudioSessionRecordPermissionGranted){
            return SAAuthorizationStatusAuthorized;
        } else {
            return SAAuthorizationStatusUnknown;
        }
    } else if (authorizationType == SAAuthorizationTypePhoto) {
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            return SAAuthorizationStatusNotDetermined;
        } else if (authorizationStatus == PHAuthorizationStatusDenied) {
            return SAAuthorizationStatusDenied;
        } else if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            return SAAuthorizationStatusAuthorized;
        } else {
            return SAAuthorizationStatusUnknown;
        }
    } else {
        NSLog(@"unImplement authorization Type");
        return SAAuthorizationStatusUnknown;
    }
}

- (void)requestAuthorization:(SAAuthorizationType)authorizationType
                      result:(void (^)(SAAuthorizationStatus status))resultBlock {
    if (authorizationType == SAAuthorizationTypeAudio) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    resultBlock(SAAuthorizationStatusAuthorized);
                } else {
                    resultBlock(SAAuthorizationStatusDenied);
                }
            });
        }];
    } else if (authorizationType == SAAuthorizationTypePhoto) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SAAuthorizationStatus saStatus = SAAuthorizationStatusUnknown;
                if (status == PHAuthorizationStatusAuthorized) {
                    saStatus = SAAuthorizationStatusAuthorized;
                } else if (status == PHAuthorizationStatusDenied) {
                    saStatus = SAAuthorizationStatusDenied;
                } else {
                    NSLog(@"request photo authorization unknown status");
                }
                resultBlock(saStatus);
            });
        }];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"unknown authorization type");
            resultBlock(SAAuthorizationStatusUnknown);
        });
    }
}

- (void)checkPhotoLibraryPermission:(void (^)(BOOL hasPermission))block {
    [self requestAuthorization:SAAuthorizationTypePhoto result:^(SAAuthorizationStatus status) {
        block(status == SAAuthorizationStatusAuthorized);
    }];
}

@end


@implementation PPPermissionManager (Alert)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!_selectedBlock) {
        return;
    }
    _selectedBlock(buttonIndex);
}


- (void)showPhotoLibraryPermissionAlert{
    [self showPhotoLibraryPermissionAlertWithCompletion:^(NSInteger selectedIndex) {
        if (selectedIndex == 1) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}


- (void)showPhotoLibraryPermissionAlertWithCompletion:(void (^)(NSInteger selectedIndex))completion{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"视频需要你相册的权限" message: @"请在iPhone的“设置-隐私-照片”选项中，允许本游戏访问你的手机相册"  delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
    _selectedBlock = [completion copy];
    [alert show];
}

- (void)showAlertWithTitle:(NSString *)titile
                   message:(NSString *)message
                   buttons:(NSArray<NSString *> *)buttons
                clickBlock:(void (^)(NSInteger selectedIndex))block {
    if (!buttons.count) {
        buttons = @[@"确定"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titile message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [buttons enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alert addButtonWithTitle:obj];
    }];
    alert.delegate = self;
    _selectedBlock = [block copy];
    [alert show];
}
@end
