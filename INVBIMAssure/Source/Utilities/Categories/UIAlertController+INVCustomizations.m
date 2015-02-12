//
//  AlertController+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "UIAlertController+INVCustomizations.h"
#import "INVStockThumbnailCollectionViewController.h"

static inline void _copyPopoverPresentationAttributes(
    UIPopoverPresentationController *to, UIPopoverPresentationController *from)
{
    to.popoverLayoutMargins = from.popoverLayoutMargins;
    to.backgroundColor = from.backgroundColor;
    to.passthroughViews = from.passthroughViews;
    to.popoverBackgroundViewClass = from.popoverBackgroundViewClass;
    to.barButtonItem = from.barButtonItem;
    to.sourceView = from.sourceView;
    to.sourceRect = from.sourceRect;
    to.delegate = from.delegate;
    to.permittedArrowDirections = from.permittedArrowDirections;
}

@interface _INVUIAlertControllerImageHandler
    : NSObject<UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate,
          INVStockThumbnailCollectionViewControllerDelegate>

@property (nonatomic, strong) id retainedSelf;
@property (nonatomic, copy) void (^handlerBlock)(UIImage *);

@end

@implementation UIAlertController (INVCustomizations)
- (instancetype)initWithErrorMessage:(NSString *)errorMesgFormat, ...
{
    va_list args;
    va_start(args, errorMesgFormat);

    NSString *errorMesg = [[NSString alloc] initWithFormat:errorMesgFormat arguments:args];

    va_end(args);

    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    self = [UIAlertController alertControllerWithTitle:nil message:errorMesg preferredStyle:UIAlertControllerStyleAlert];

    if (self) {
        [self addAction:action];
    }

    return self;
}

- (instancetype)initForImageSelectionWithHandler:(void (^)(UIImage *))handler
{
    // This is used for holding the current popover attributes assigned to this controller
    __block UIPopoverPresentationController *holdingPopoverController = nil;

    // Because the popover is dismissed *before* the callback is called, we need to also store the presenting view controller.
    __block UIViewController *presentingViewController = nil;

    // The delegate used for handling all of our callbacks.
    _INVUIAlertControllerImageHandler *imageHandlerDelegate = [[_INVUIAlertControllerImageHandler alloc] init];
    imageHandlerDelegate.retainedSelf = imageHandlerDelegate; // Must retain itself as delegates are stored as weak references.
    imageHandlerDelegate.handlerBlock = handler;

    self = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [self addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"STOCK_IMAGES", nil)
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               INVStockThumbnailCollectionViewController *stockThumbnailController =
                                                   [[INVStockThumbnailCollectionViewController alloc] init];
                                               stockThumbnailController.delegate = imageHandlerDelegate;

                                               stockThumbnailController.modalPresentationStyle = UIModalPresentationPopover;
                                               stockThumbnailController.preferredContentSize = CGSizeMake(320, 320);

                                               [presentingViewController presentViewController:stockThumbnailController
                                                                                      animated:YES
                                                                                    completion:nil];

                                               _copyPopoverPresentationAttributes(
                                                   stockThumbnailController.popoverPresentationController,
                                                   holdingPopoverController);
                                           }]];

    [self addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PHOTO_LIBRARY", nil)
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               UIImagePickerController *imagePickerController =
                                                   [[UIImagePickerController alloc] init];
                                               imagePickerController.delegate = imageHandlerDelegate;
                                               imagePickerController.allowsEditing = NO;
                                               imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                                               imagePickerController.modalPresentationStyle = UIModalPresentationPopover;

                                               [presentingViewController presentViewController:imagePickerController
                                                                                      animated:YES
                                                                                    completion:nil];

                                               _copyPopoverPresentationAttributes(
                                                   imagePickerController.popoverPresentationController,
                                                   holdingPopoverController);
                                           }]];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"TAKE_PHOTO", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   UIImagePickerController *imagePickerController =
                                                       [[UIImagePickerController alloc] init];
                                                   imagePickerController.delegate = imageHandlerDelegate;
                                                   imagePickerController.allowsEditing = NO;
                                                   imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                   imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;

                                                   [presentingViewController presentViewController:imagePickerController
                                                                                          animated:YES
                                                                                        completion:nil];
                                               }]];
    }

    [self
        addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil]];

    // The popover presentation controller does not exist until we actually present the view controller, due to apple's 'wisdom'
    dispatch_async(dispatch_get_main_queue(), ^{
        presentingViewController = self.presentingViewController;
        holdingPopoverController =
            [[UIPopoverPresentationController alloc] initWithPresentedViewController:nil
                                                            presentingViewController:presentingViewController];

        _copyPopoverPresentationAttributes(holdingPopoverController, self.popoverPresentationController);

        holdingPopoverController.delegate = imageHandlerDelegate;
    });

    return self;
}

@end

@implementation _INVUIAlertControllerImageHandler

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    self.handlerBlock(image);

    [picker.presentingViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            self.retainedSelf = nil;
                                                        }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            self.retainedSelf = nil;
                                                        }];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    self.retainedSelf = nil;
}

- (void)stockThumbnailCollectionViewController:(INVStockThumbnailCollectionViewController *)controller
                       didSelectStockThumbnail:(UIImage *)image
{
    self.handlerBlock(image);

    [controller.presentingViewController dismissViewControllerAnimated:YES
                                                            completion:^{
                                                                self.retainedSelf = nil;
                                                            }];
}

@end