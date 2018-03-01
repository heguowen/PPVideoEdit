//
//  PPDrawLayer.m
//  pop
//
//  Created by neil on 2017/10/24.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPDrawLayer.h"
#define PPDRAWINGPATHWIDTH 6
#define PPDRAWINGBUFFER 12
#define PPDRAWINGORIGINCOLOR [UIColor whiteColor].CGColor

@interface PPDrawLayer()
@property (nonatomic, assign) CGPoint previousPoint1;
@property (nonatomic, assign) CGPoint previousPoint2;
@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation PPDrawLayer

- (instancetype)init {
    if (self = [self initWithStartPoint:CGPointZero]) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint {
    if (self = [super init]) {
        [self doInit];
        self.previousPoint2 = self.previousPoint1 = self.currentPoint = startPoint;
    }
    return self;
}

- (void)doInit {
    self.frame = [UIScreen mainScreen].bounds;
    self.lineJoin = kCALineJoinRound;
    self.lineCap = kCALineCapRound;
    self.strokeColor = self.fillColor = PPDRAWINGORIGINCOLOR;
    self.lineWidth = PPDRAWINGPATHWIDTH;
}

+ (instancetype)layerWithStartPoint:(CGPoint)startPoint {
    PPDrawLayer *layer = [[[self class] alloc] initWithStartPoint:startPoint];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:startPoint];
    layer.path = path.CGPath;
    return layer;
}

- (void)updatePoint:(CGPoint)newPoint {
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = self.currentPoint;
    self.currentPoint = newPoint;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGPoint mid1 = midPoint(self.previousPoint1, self.previousPoint2);
    CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.path];
    self.strokeColor = [UIColor whiteColor].CGColor;
    [path moveToPoint:mid1];
    [path addQuadCurveToPoint:mid2 controlPoint:self.previousPoint1];
    self.path = path.CGPath;
}

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}
@end
