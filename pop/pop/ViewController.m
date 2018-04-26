//
//  ViewController.m
//  pop
//
//  Created by neil on 2017/9/11.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "ViewController.h"
#import "PPVideoEditController.h"
#import "PPToast.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "PPVideoEditController.h"
#import "UIStoryboard+LoadController.h"
#import "TZImagePickerController.h"

@interface ViewController ()<TZImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    TZImagePickerController *_picker;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onImportClick:(id)sender {

#if USE_SYSTEM_IMAGE_PICKER
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
#else

    if (!_picker) {
        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        imagePicker.allowTakePicture = NO;
        imagePicker.allowPickingImage = NO;
        imagePicker.isStatusBarDefault = NO;
        imagePicker.sortAscendingByModificationDate = YES;
        
        _picker = imagePicker;
    }
    WS(weakSelf);
    [_picker setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
        PHAsset *theAsset = (PHAsset *)asset;

        PPVideoEditController *editController = (PPVideoEditController *)[UIStoryboard loadControllerWithStoryBoardName:@"PPVideoEdit" withController:[PPVideoEditController class]];
        [editController loadViewWithPHAsset:theAsset];
        [weakSelf presentViewController:editController animated:YES completion:nil];
    }];
    [self presentViewController:_picker animated:YES completion:nil];
#endif
}

#pragma mark - TSAssetsPickerControllerDataSource

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
}


@end
