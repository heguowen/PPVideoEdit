//
//  Helper+System.m
//  guimiquan
//
//  Created by Daly on 14/11/27.
//  Copyright (c) 2014年 Vanchu. All rights reserved.
//

#import "PPHelper+System.h"
#import <UIKit/UIKit.h>
//#import "ServiceManager.h"
#import "sys/utsname.h"




@implementation PPHelper (System)

+ (BOOL)isEqualToIOS6 {
    
    static dispatch_once_t pred_isEqualToIOS6;
    static BOOL cacheIsEqualToIOS6;
    dispatch_once(&pred_isEqualToIOS6, ^{
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            cacheIsEqualToIOS6 = YES;
        }
        else {
            cacheIsEqualToIOS6 = NO;
        }
    });
    
    return cacheIsEqualToIOS6;
}

+ (BOOL)isEqualToIOS7 {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        return YES;
    return NO;
}

+ (BOOL)isGreaterOrEqualToIOS7 {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        return YES;
    return NO;
}

+ (BOOL)isGreaterOrEqualToIOS8 {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        return YES;
    return NO;
}

+ (BOOL)isEqualToIPhone6 {
    NSString *deviceString = [PPHelper deviceString];
    
//    NSLog(@"deviceString = %@", deviceString);
    
    if ([deviceString isEqualToString:@"iPhone7,2"]) {
        return YES;
    }
    if (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEqualToIPhone6Plus {
    
    NSString *deviceString = [PPHelper deviceString];
    
//    NSLog(@"deviceString = %@", deviceString);
    
    if ([deviceString isEqualToString:@"iPhone7,1"]) {
        return YES;
    }
    if (CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEqualToSmallScreen {
    CGRect rx = [ UIScreen mainScreen ].bounds;
    if (rx.size.height <= 480) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}

+ (NSString *)getDeviceID {
#if TARGET_IPHONE_SIMULATOR
	NSUUID *deviceId = [[NSUUID alloc] initWithUUIDString:@"bec26202-a8d8-4a94-80fc-9ac1de37daa6"];
#else
	NSUUID *deviceId = [UIDevice currentDevice].identifierForVendor;
#endif
	return [deviceId UUIDString];
}

//+ (NSData *)getPushDeviceToken {
//    return OBTAIN_SERVICE(PushService).pushDeviceToken;
//}
//
//+ (NSString *)getPushDeviceTokenStr {
//    return  OBTAIN_SERVICE(PushService).pushDeviceTokenStr;
//}

+ (NSString *)getSysModel {
    return [[UIDevice currentDevice] model];
}

+ (NSString *)getSysName {
    return [[UIDevice currentDevice] systemName];
}

/**
 *  系统版本
 *
 *  @return 
 */
+ (NSString *)getSysVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceString {
    // 需要#import "sys/utsname.h"
    static dispatch_once_t pred_deviceString;
    static NSString *cache_deviceString;
    dispatch_once(&pred_deviceString, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        cache_deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    return cache_deviceString;
}
/**
 * app 版本
 */

+ (NSString *)appVersion {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	return app_Version;
}

+ (CGFloat)screenScale {
    static CGFloat scale = 0.0f;
    if (scale > 0) {
        return scale;
    } else {
        scale = [UIScreen mainScreen].scale;
        return scale;
    }
}
@end
