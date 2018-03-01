//
//  PPVideoEditDefines.h
//  pop
//
//  Created by neil on 2017/9/14.
//  Copyright © 2017年 neil. All rights reserved.
//

#ifndef PPVideoEditDefines_h
#define PPVideoEditDefines_h

#ifndef kCMTimeScale
#define  kCMTimeScale  600.0f
#endif

typedef NS_ENUM(NSInteger, PPRenderSourceType) {
    PPRenderSourceTypeNone  = 0,
    PPRenderSourceTypeEmoji = 1,
    PPRenderSourceTypeDraw  = 2,
    PPRenderSourceTypeText  = 3,
};

#ifndef PPRenderSourceTypeStr
#define PPRenderSourceTypeStr NSString
#endif

#ifndef PPVideoEditOptionStr
#define PPVideoEditOptionStr NSString
#endif

NSString *stringWithImageSourceType(PPRenderSourceType input);

typedef NS_ENUM(NSInteger, PPVideoEditOption) {
    PPVideoEditOptionClip  = 0,
    PPVideoEditOptionEmoji = 1,
    PPVideoEditOptionDraw  = 2,
    PPVideoEditOptionText  = 3,
};

NSString *stringWithEditOption(PPVideoEditOption input);

PPRenderSourceType editOption2SourceType(PPVideoEditOption editOption);

PPVideoEditOption sourceType2EditOption(PPRenderSourceType type);

#endif /* PPVideoEditDefines_h */
