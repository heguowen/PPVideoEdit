
//
//  PPRenderResultDefines.h
//  pop
//
//  Created by neil on 2017/10/9.
//  Copyright © 2017年 neil. All rights reserved.
//

#ifndef PPRenderResultDefines_h
#define PPRenderResultDefines_h
typedef NS_ENUM(NSInteger,PPRenderResultType) {
    PPRenderResultTypeLayer = 0,
    PPRenderResultTypeEmoji = 1,
    PPRenderResultTypeText = 2,
};

#ifndef PPRenderTextResultDidChangeStateNotification
#define PPRenderTextResultDidChangeStateNotification @"PPRenderTextResultDidChangeStateNotification"
#endif

#endif /* PPRenderResultDefines_h */
