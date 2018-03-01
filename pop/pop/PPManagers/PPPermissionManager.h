//
//  SAPermissionManager.h
//  GRFoundation
//
//  Created by neil on 16/11/21.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SAAuthorizationType) {
    SAAuthorizationTypeUnknown = 0,
    SAAuthorizationTypeAudio = 1,
    SAAuthorizationTypePhoto = 2,
};


typedef NS_ENUM(NSInteger, SAAuthorizationStatus) {
    SAAuthorizationStatusUnknown = 0,
    SAAuthorizationStatusNotDetermined = 1,
    SAAuthorizationStatusAuthorized = 2,
    SAAuthorizationStatusDenied = 3,
};


@interface PPPermissionManager : NSObject

+ (instancetype)sharedInstance;

/** 当前App是否有某种权限，只进行询问，而不会去请求权限 */
- (SAAuthorizationStatus)authorizationStatusWithType:(SAAuthorizationType)authorizationType;

/** 请求授权，与 authorizationStatusWithType:的区别在于当前方法会向系统请求权限。 resultBlock run in main thread */
- (void)requestAuthorization:(SAAuthorizationType)authorizationType
                      result:(void (^)(SAAuthorizationStatus status))resultBlock;


- (void)checkPhotoLibraryPermission:(void (^)(BOOL hasPermission))block;

@end


@interface PPPermissionManager (Alert)

/** 展示一个提示开启相册权限弹框 */
- (void)showPhotoLibraryPermissionAlert;

- (void)showAlertWithTitle:(NSString *)titile message:(NSString *)message buttons:(NSArray<NSString *> *)buttons clickBlock:(void (^)(NSInteger selectedIndex))block;



@end
