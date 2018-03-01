//
//  SADirectoryManager.m
//  GRFoundation
//
//  Created by chance on 14/6/2016.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import "PPDirectoryManager.h"

#define kSDKDirectoryName @"PopLab"
#define kLogDirectoryName @"PopLabLog"
#define kTempDirectoryName @"PopLabTemp"

@implementation PPDirectoryManager {
    NSString *_sdkDirectory;
    NSString *_userDirectory;
    NSString *_shareDirectory;
    NSString *_tempDirectory;
    NSString *_videoDirectory;
    NSString *_manualVideosDirectory;
    NSString *_momentVideosDirectory;
    NSString *_tempAudioDirectory;
    NSString *_judgementVideoDirectory;
    NSString *_logDirectory;
}

+ (instancetype)sharedManager {
    static PPDirectoryManager *sharedManager = nil;
    if (!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!sharedManager) {
                sharedManager = [PPDirectoryManager new];
            }
        });
    }
    return sharedManager;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        // 小于V1.5以下版本，删除旧文件目录
        [self cleanOldDirectories];
    }
    return self;
}


- (NSString *)sdkDirectory {
    if (!_sdkDirectory) {
        @synchronized(self) {
            if (!_sdkDirectory) {
                NSString *path = [[self documentDirectory] stringByAppendingPathComponent:kSDKDirectoryName];
                if ([self createDirectoryAtPath:path]) {
                    _sdkDirectory = [path copy];
                }
            }
        }
    }
    return _sdkDirectory;
}


- (NSString *)shareDirectory {
    if (!_shareDirectory) {
        @synchronized(self) {
            if (!_shareDirectory) {
                NSString *path = [[self documentDirectory] stringByAppendingFormat:@"/%@/Share", kSDKDirectoryName];
                if ([self createDirectoryAtPath:path]) {
                    _shareDirectory = [path copy];
                }
            }
        }
    }
    return _shareDirectory;
}


- (NSString *)logDirectory {
    if (!_logDirectory) {
        @synchronized(self) {
            if (!_logDirectory) {
                NSString *path = [[self cachesDirectory] stringByAppendingPathComponent:kLogDirectoryName];
                if ([self createDirectoryAtPath:path]) {
                    _logDirectory = [path copy];
                }
            }
        }
    }
    return _logDirectory;
}

- (NSString *)tempDirectory {
    if (!_tempDirectory) {
        @synchronized(self) {
            if (!_tempDirectory) {
                NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:kTempDirectoryName];
                if ([self createDirectoryAtPath:path]) {
                    _tempDirectory = [path copy];
                }
            }
        }
    }
    return _tempDirectory;
}


- (NSString *)videoDirectory {
    if (!_videoDirectory) {
        NSString *tempDirectory = [self tempDirectory];
        @synchronized(self) {
            if (!_videoDirectory) {
                NSString *path = [tempDirectory stringByAppendingPathComponent:@"Video"];
                if ([self createDirectoryAtPath:path]) {
                    _videoDirectory = [path copy];
                }
            }
        }
    }
    return _videoDirectory;
}



- (NSString *)tempAudioDirectory {
    if (!_tempAudioDirectory) {
        NSString *tempDirectory = [self tempDirectory];
        @synchronized(self) {
            if (!_tempAudioDirectory) {
                NSString *path = [tempDirectory stringByAppendingPathComponent:@"Audio"];
                if ([self createDirectoryAtPath:path]) {
                    _tempAudioDirectory = [path copy];
                }
            }
        }
    }
    return _tempAudioDirectory;
}


#pragma mark - User Directory

- (NSString *)userDirectory {
    NSString *directory = nil;
    @synchronized (self) {
        directory = _userDirectory;
    }
    return directory;
}


- (void)switchUserDirectoryWithHashID:(NSString *)hashID {
    if (!hashID.length) {
        _userDirectory = nil;
        return;
    }
    NSString *userDirectoryPath = [[self documentDirectory] stringByAppendingFormat:@"/%@/Users/%@", kSDKDirectoryName, hashID];
    if ([userDirectoryPath isEqualToString:_userDirectory]) {
        return;
    }
    @synchronized (self) {
        if ([self createDirectoryAtPath:userDirectoryPath]) {
            _userDirectory = [userDirectoryPath copy];
            
        } else {
            _userDirectory = nil;
        }
    }
}


// 清空目录下的文件
- (BOOL)cleanDirectory:(NSString *)directoryPath {
    if (!directoryPath.length) {
        NSLog(@"SADirectoryManager directory is not existed");
        return NO;
    }
    NSLog(@"SADirectoryManager clean directory: %@", directoryPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isOK = YES;
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        // delete file
        NSError *removeError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
        NSLog(@"Delete File: %@ %@", fileName, removeError ? removeError : @"OK");
        if (isOK && removeError) {
            isOK = NO;
        }
    }
    return isOK;
}


#pragma mark - Private

- (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.count ? [paths lastObject] : nil;
}

- (NSString *)cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths.count ? [paths lastObject] : nil;
}


- (BOOL)createDirectoryAtPath:(NSString *)directoryPath {
    if (!directoryPath.length) {
        return NO;
    }
    // 检查目录是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        NSError *error;
        BOOL isOK = [fileManager createDirectoryAtPath:directoryPath
                           withIntermediateDirectories:YES
                                            attributes:nil
                                                 error:&error];
        if (!isOK) {
            NSLog(@"SADictionaryManager fail to create directory:%@ %@", directoryPath, error);
        }
        return isOK;
        
    } else {
        return YES;
    }
}


#pragma mark - others
// 清理旧文件目录
- (void)cleanOldDirectories {
    NSString *sdkDirectory = [[self documentDirectory] stringByAppendingPathComponent:kSDKDirectoryName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // remove log directory
    NSString *logDirectory = [sdkDirectory stringByAppendingPathComponent:@"Log"];
    if ([fileManager fileExistsAtPath:logDirectory]) {
        NSError *error;
        BOOL isOK = [fileManager removeItemAtPath:logDirectory error:&error];
        if (!isOK) {
            NSLog(@"Fail to delete old log directory: %@", error);
        }
    }
    // remove video directory
    NSString *videoDiretory = [sdkDirectory stringByAppendingPathComponent:@"Video"];
    if ([fileManager fileExistsAtPath:videoDiretory]) {
        [fileManager removeItemAtPath:videoDiretory error:nil];
    }
}


@end


#pragma mark -
#define kUserDefaultsFileName @"user_defaults"

@implementation PPUserDefaults (UsingSDKDirectory)

+ (instancetype)sharedUserDefaults {
    if (![PPDirectoryManager sharedManager].shareDirectory) {
        return nil;
    }
    static PPUserDefaults *sSharedUserDefaults = nil;
    if (!sSharedUserDefaults) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *filePath = [[PPDirectoryManager sharedManager].shareDirectory stringByAppendingPathComponent:kUserDefaultsFileName];
            sSharedUserDefaults = [[PPUserDefaults alloc] initWithPath:filePath];
        });
    }
    return sSharedUserDefaults;
}


static PPUserDefaults *sCurrentUserDefaults = nil;
+ (instancetype)currentUserDefaults {
    PPUserDefaults *currentUserDefaults = nil;
    @synchronized(self) {
        currentUserDefaults = sCurrentUserDefaults;
    }
    return currentUserDefaults;
}


+ (void)switchCurrentUserDefaultsWithPath:(NSString *)userDefaultDirectory {
    NSString *filePath = [userDefaultDirectory stringByAppendingPathComponent:kUserDefaultsFileName];
    @synchronized(self) {
        if (filePath) {
            sCurrentUserDefaults = [[PPUserDefaults alloc] initWithPath:filePath];
            
        } else {
            sCurrentUserDefaults = nil;
        }
    }
}


@end


