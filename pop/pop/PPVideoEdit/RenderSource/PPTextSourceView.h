//
//  PPTextImageView.h
//  pop
//
//  Created by neil on 2017/9/13.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRenderSourceView.h"

@class PPTextSourceView;
@protocol PPTextSourceViewDelegate <PPRenderSourceViewDelegate>
@required

- (void)textSourceViewCancelEdit:(PPTextSourceView *)textView;
@end

@interface PPTextSourceView : PPRenderSourceView
@property (nonatomic, weak) id<PPTextSourceViewDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isNewText;

@property (nonatomic, strong) NSString *originText;

@end



