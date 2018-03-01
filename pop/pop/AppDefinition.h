//
//  AppDefinition.h
//  pop
//
//  Created by neil on 2017/9/27.
//  Copyright © 2017年 neil. All rights reserved.
//

#ifndef AppDefinition_h
#define AppDefinition_h
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define LineViewColor UIColor(226, 226, 226, 1)
//屏幕尺寸
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCALE [[UIScreen mainScreen] bounds].size.width / 320
#define UIScale(x) x * SCALE

//字符串转换
#define ToString(x) [NSString stringWithFormat:@"%@",x]
#define UIColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIFont(x) [UIFont systemFontOfSize:x]

#define USE_SYSTEM_IMAGE_PICKER 0

#endif /* AppDefinition_h */
