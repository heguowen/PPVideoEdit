//
//  PPVideoEditBaseView.h
//  pop
//
//  Created by neil on 2017/9/26.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPVideoEditBaseViewProtocol;
@interface PPVideoEditBaseView : UIView

@property (nonatomic, weak) id<PPVideoEditBaseViewProtocol> delegate;


/**
是否自带工具栏
 */
- (BOOL)useSelfToolBar;
/**
 展示该视图，该方法由子类重写，要注意的是：该方法有可能会多次调用，所以一些初始化操作最好不要放里面
 */
- (void)showSelf;

/**
 隐藏该视图，该方法由子类重写，要注意的是：该方法有可能会多次调用，所以一些初始化操作最好不要放里面
 */
- (void)hiddenSelf;
@end

@protocol PPVideoEditBaseViewProtocol <NSObject>

- (void)editViewWillShow:(PPVideoEditBaseView *)view;

- (void)editViewWillHidden:(PPVideoEditBaseView *)view;

@end
