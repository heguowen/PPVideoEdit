//
//  PPHelper+Draw.m
//  pop
//
//  Created by neil on 2017/9/15.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPHelper+Draw.h"
#import <CoreText/CoreText.h>

@implementation PPHelper (Draw)
+ (UIImage *)drawImageForString:(NSString *)string
                     attributes:(NSDictionary *)attributes
                           size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
