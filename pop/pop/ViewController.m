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
    // Do any additional setup after loading the view, typically from a nib.
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
//- (NSUInteger)numberOfItemsToSelectInAssetsPickerController:(TSAssetsPickerController *)picker {
//    return 1;
//}
//
//- (TSFilter *)filterOfAssetsPickerController:(TSAssetsPickerController *)picker {
//    return [TSFilter filterWithType:FilterTypeVideo];
//}
//
//#pragma mark - TSAssetsPickerControllerDelegate
//- (void)assetsPickerControllerDidCancel:(TSAssetsPickerController *)picker {
//    [_picker dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)assetsPickerController:(TSAssetsPickerController *)picker didFinishPickingAssets:(NSArray<ALAsset *> *)assets {
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_picker dismissViewControllerAnimated:YES completion:^{
//            PPVideoEditController *editController = (PPVideoEditController *)[UIStoryboard loadControllerWithStoryBoardName:@"PPVideoEdit" withController:[PPVideoEditController class]];
//            [editController loadVideoWithAlAsset:[assets firstObject]];
//            [self presentViewController:editController animated:YES completion:^{
//                
//            }];
//        }];
//    });
//}
//
//- (void)assetsPickerController:(TSAssetsPickerController *)picker failedWithError:(NSError *)error {
//    if (error) {
//        NSLog(@"Error occurs. Show dialog or something. Probably because user blocked access to Camera Roll.");
//    }
//}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self dismissViewControllerAnimated:YES completion:^{
//            PPVideoEditController *editController = (PPVideoEditController *)[UIStoryboard loadControllerWithStoryBoardName:@"PPVideoEdit" withController:[PPVideoEditController class]];
//            [editController loadVideoWithUrl:url];
//            [self presentViewController:editController animated:YES completion:^{
//                
//            }];
//        }];
    });
}


@end
