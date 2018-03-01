//
//  UIView+FrameMethods.m
//  iphoneApp
//
//  Created by 李煜 on 13-11-14.
//
//

#import "UIView+FrameMethods.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (FrameMethods)


-(CGFloat)x
{
    CGRect origionRect = self.frame;
    return origionRect.origin.x;
}

-(CGFloat)y
{
    CGRect origionRect = self.frame;
    return origionRect.origin.y;
}

-(CGFloat)centerX
{
    return self.center.x;
}

-(CGFloat)centerY
{
    return self.center.y;
}

-(CGFloat)width
{
    CGRect origionRect = self.frame;
    return origionRect.size.width;
}

-(CGFloat)height
{
    CGRect origionRect = self.frame;
    return origionRect.size.height;
}

- (CGSize)size
{
    CGRect origionRect = self.frame;
    return origionRect.size;
}



-(void)setCenterX:(CGFloat)centerX
{
    CGPoint centerPoint = self.center;
    centerPoint.x = centerX;
    self.center = centerPoint;
}

-(void)setCenterY:(CGFloat)centerY
{
    CGPoint centerPoint = self.center;
    centerPoint.y = centerY;
    self.center = centerPoint;
}

-(void)setX:(CGFloat)x
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(x, origionRect.origin.y, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

-(void)setY:(CGFloat)y
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, y, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)moveHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x + horizontal, origionRect.origin.y + vertical, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)moveHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical addWidth:(CGFloat)widthAdded addHeight:(CGFloat)heightAdded
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x + horizontal,
                                origionRect.origin.y + vertical,
                                origionRect.size.width + widthAdded,
                                origionRect.size.height + heightAdded);
    self.frame = newRect;
}

- (void)moveToHorizontal:(CGFloat)horizontal toVertical:(CGFloat)vertical
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(horizontal, vertical, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)moveToHorizontal:(CGFloat)horizontal toVertical:(CGFloat)vertical setWidth:(CGFloat)width setHeight:(CGFloat)height
{
    CGRect newRect = CGRectMake(horizontal, vertical, width, height);
    self.frame = newRect;
}

- (void)setWidth:(CGFloat)width height:(CGFloat)height
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, width, height);
    self.frame = newRect;
}

- (void)setWidth:(CGFloat)width
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, width, origionRect.size.height);
    self.frame = newRect;
}

- (void)setHeight:(CGFloat)height
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, origionRect.size.width, height);
    self.frame = newRect;
}

- (void)setSize:(CGSize)size
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, size.width, size.height);
    self.frame = newRect;
}

- (void)setOriginX:(CGFloat)x originY:(CGFloat)y
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(x, y, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)setOriginX:(CGFloat)x
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(x, origionRect.origin.y, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)setOriginY:(CGFloat)y
{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(origionRect.origin.x, y, origionRect.size.width, origionRect.size.height);
    self.frame = newRect;
}

- (void)addWidth:(CGFloat)widthAdded addHeight:(CGFloat)heightAdded
{
    CGRect originRect = self.frame;
    CGFloat newWidth = originRect.size.width + widthAdded;
    CGFloat newHeight = originRect.size.height + heightAdded;
    CGRect newRect = CGRectMake(originRect.origin.x, originRect.origin.y, newWidth, newHeight);
    self.frame = newRect;
}

- (void)addWidth:(CGFloat)widthAdded
{
    [self addWidth:widthAdded addHeight:0];
}

- (void)addHeight:(CGFloat)heightAdded
{
    [self addWidth:0 addHeight:heightAdded];
}

- (void)setCornerRadius:(CGFloat)radius
{
    [self setCornerRadius:radius borderColor:[UIColor grayColor]];
}

- (void)setCornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor
{
    [self.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.layer setBorderColor:[borderColor CGColor]];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:radius];
    [self.layer setMasksToBounds:YES];
    self.clipsToBounds = YES;
}

- (void)setBorder:(CGFloat)width borderColor:(UIColor *)borderColor
{
    [self.layer setBorderColor:[borderColor CGColor]];
    [self.layer setBorderWidth:width];
}

- (CGRect)frameInWindow
{
    CGRect frameInWindow = [self.superview convertRect:self.frame
                                                toView:self.window];
    return frameInWindow;
}

@end
