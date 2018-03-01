//
//  PPVideoEditDefines.m
//  pop
//
//  Created by neil on 2017/9/14.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPVideoEditDefines.h"

NSString *stringWithEditOption(PPVideoEditOption input) {
    NSArray *PPVideoEditOptions = @[@"PPVideoEditOptionClip",
                                    @"PPVideoEditOptionEmoji",
                                    @"PPVideoEditOptionDraw",
                                    @"PPVideoEditOptionText"];
    return (NSString *)[PPVideoEditOptions objectAtIndex:input];
}

NSString *stringWithImageSourceType(PPRenderSourceType input) {
    NSArray *PPImageSourceTypes = @[@"PPImageSourceTypeNone",
                                    @"PPImageSourceTypeEmoji",
                                    @"PPImageSourceTypeDraw",
                                    @"PPImageSourceTypeText"];
    return (NSString *)[PPImageSourceTypes objectAtIndex:input];
}

PPRenderSourceType editOption2SourceType(PPVideoEditOption editOption){
    return (PPRenderSourceType)editOption;
}

PPVideoEditOption sourceType2EditOption(PPRenderSourceType type) {
    return (PPVideoEditOption)type;
}
