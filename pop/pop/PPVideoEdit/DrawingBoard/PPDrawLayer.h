//
//  PPDrawLayer.h
//  pop
//
//  Created by neil on 2017/10/24.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PPDrawLayer : CAShapeLayer

+ (instancetype)layerWithStartPoint:(CGPoint)startPoint;

- (instancetype)initWithStartPoint:(CGPoint)startPoint NS_DESIGNATED_INITIALIZER;


- (void)updatePoint:(CGPoint)newPoint;


+ (instancetype)new NS_UNAVAILABLE;





@end
