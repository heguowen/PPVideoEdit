//
//  UIView+FrameMethods.h
//  iphoneApp
//
//  Created by 李煜 on 13-11-14.
//
//

#import <UIKit/UIKit.h>

@interface UIView(FrameMethods)

@property(nonatomic,assign) CGFloat x;
@property(nonatomic,assign) CGFloat y;

@property(nonatomic,assign) CGFloat centerX;
@property(nonatomic,assign) CGFloat centerY;

@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;

@property(nonatomic,assign) CGSize size;

//Move methods

- (void)moveHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical;

- (void)moveHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical addWidth:(CGFloat)widthAdded addHeight:(CGFloat)heightAdded;

- (void)moveToHorizontal:(CGFloat)horizontal toVertical:(CGFloat)vertical;

- (void)moveToHorizontal:(CGFloat)horizontal toVertical:(CGFloat)vertical setWidth:(CGFloat)width setHeight:(CGFloat)height;

//Set width/height

- (void)setWidth:(CGFloat)width height:(CGFloat)height;

- (void)setWidth:(CGFloat)width;

- (void)setHeight:(CGFloat)height;

//Add orginX/OrginY

- (void)setOriginX:(CGFloat)x originY:(CGFloat)y;

- (void)setOriginX:(CGFloat)x;

- (void)setOriginY:(CGFloat)y;

//Add width/height

- (void)addWidth:(CGFloat)widthAdded addHeight:(CGFloat)heightAdded;

- (void)addWidth:(CGFloat)widthAdded;

- (void)addHeight:(CGFloat)heightAdded;

//Set corner radius

- (void)setCornerRadius:(CGFloat)radius;

- (void)setCornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor;

//Set border
- (void)setBorder:(CGFloat)width borderColor:(UIColor *)borderColor;

- (CGRect)frameInWindow;

@end
