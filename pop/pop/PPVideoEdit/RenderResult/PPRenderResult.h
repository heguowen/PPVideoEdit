//
//  PPRenderResult.h
//  pop
//
//  Created by neil on 2017/9/21.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPRenderResultDefines.h"

@interface PPRenderResult : NSObject

@property (nonatomic, assign, readonly) NSInteger tagId;

@property (nonatomic, strong) id content; //subclass attribute
@property (nonatomic, assign, readonly) PPRenderResultType type;
@property (nonatomic, assign) CGRect frame;


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

+ (instancetype)renderResultWithType:(PPRenderResultType )type;
@end

