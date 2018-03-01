//
//  PPHelper+Draw.h
//  pop
//
//  Created by neil on 2017/9/15.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPHelper.h"

@interface PPHelper (Draw)


+ (UIImage *)drawImageForString:(NSString *)string
                     attributes:(NSDictionary *)attributes
                           size:(CGSize)size;

@end
