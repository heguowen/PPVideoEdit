//
//  PPVideoBaseProcess.h
//  pop
//
//  Created by neil on 2017/10/10.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PPTimeStamp.h"

@interface PPVideoBaseProcess : NSObject

@property(nonatomic, strong) AVAsset *videoAsset;

- (instancetype)initWithAsset:(AVAsset *)asset;

//- (instancetype)initWithPHAsset:()

- (instancetype)initWithURL:(NSURL *)url;

//- (void)exportDidFinish:(AVAssetExportSession*)session;

//- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;

- (void)videoOutputWithTimeRange:(PPTimeStamp *)timeStamp
                  WithCompletion:(void (^)(NSURL *url))completion;
@end



