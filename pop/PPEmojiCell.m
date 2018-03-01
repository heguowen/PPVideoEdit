//
//  PPEmojiCell.m
//  pop
//
//  Created by neil on 2017/9/12.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "PPEmojiCell.h"

@interface PPEmojiCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PPEmojiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)feedData:(UIImage *)image {
    self.imageView.image = image;
}


@end
