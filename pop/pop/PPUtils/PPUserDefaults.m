//
//  SAUserDefaults.m
//  GameJoyRecorderSDK
//
//  Created by chance on 9/24/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "PPUserDefaults.h"

@implementation PPUserDefaults {
    NSString *_filePath;
    NSMutableDictionary *_userDefaultDict;
    BOOL _hasChanged;
}

- (instancetype)initWithPath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        NSDictionary *existedDefaultDict = [NSDictionary dictionaryWithContentsOfFile:_filePath];
        if ([existedDefaultDict isKindOfClass:[NSDictionary class]]) {
            _userDefaultDict = [existedDefaultDict mutableCopy];
            
        } else {
            _userDefaultDict = [NSMutableDictionary dictionary];
        }
    }
    return self;
}


- (void)dealloc {
    [self synchronize];
}


- (BOOL)synchronize {
    if (!_filePath.length) return NO;
    if (!_hasChanged) return YES;
    _hasChanged = NO;
    return [_userDefaultDict writeToFile:_filePath atomically:YES];
}


- (id)objectForKey:(NSString *)defaultName {
    if (defaultName) {
        return [_userDefaultDict objectForKey:defaultName];
    }
    return nil;
}


- (void)setObject:(id)value forKey:(NSString *)defaultName {
    if (!defaultName) {
        return;
    }
    if (value && [value conformsToProtocol:@protocol(NSCoding)]) {
        [_userDefaultDict setObject:value forKey:defaultName];
        _hasChanged = YES;
    }
    if (!value && [_userDefaultDict objectForKey:defaultName]) {
        [_userDefaultDict removeObjectForKey:defaultName];
    }
}


- (void)removeObjectForKey:(NSString *)defaultName {
    [_userDefaultDict removeObjectForKey:defaultName];
    _hasChanged = YES;
}


- (NSString *)stringForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}

- (NSURL *)URLForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}


- (NSInteger)integerForKey:(NSString *)defaultName {
    NSNumber *value = [self objectForKey:defaultName];
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}


- (float)floatForKey:(NSString *)defaultName {
    NSNumber *value = [self objectForKey:defaultName];
    if (value && [value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0.0f;
}

- (double)doubleForKey:(NSString *)defaultName {
    NSNumber *value = [self objectForKey:defaultName];
    if (value && [value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0.0;
}

- (BOOL)boolForKey:(NSString *)defaultName {
    NSNumber *value = [self objectForKey:defaultName];
    if (value && [value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
    _hasChanged = YES;
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
    _hasChanged = YES;
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
    _hasChanged = YES;
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
    _hasChanged = YES;
}



@end

