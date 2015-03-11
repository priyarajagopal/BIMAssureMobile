//
//  INVImageLoader.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVImageLoader.h"

@import CoreImage;
@import ImageIO;

@interface INVLoadingImageProxy : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (id)initWithLoadingImage:(UIImage *)loadingImage inView:(UIView *)view;

- (void)fulfil:(id)image;

@end

@implementation INVLoadingImageProxy {
    size_t _width, _height;

    NSMutableData *_currentData;
    CGImageSourceRef _loadingImageSource;

    UIImage *_image;
    __weak UIView *_theView;
}

const void *INVLoadingImageProxy_CGDataProviderGetBytePointerCallback(void *info)
{
    return CFDataGetMutableBytePtr((CFMutableDataRef) info);
}

void INVLoadingImageProxy_CGDataProviderReleaseBytePointerCallback(void *info, const void *pointer)
{
    // Do nothing
}

size_t INVLoadingImageProxy_CGDataProviderGetBytesAtOffsetCallback(void *info, void *buffer, off_t offset, size_t count)
{
    CFDataGetBytes((CFDataRef) info, CFRangeMake((size_t) offset, count), buffer);

    return count;
}

void INVLoadingImageProxy_CGDataProviderReleaseInfoCallback(void *info)
{
    // Do nothing
    CFRelease((CFDataRef) info);
}

- (id)initWithLoadingImage:(UIImage *)loadingImage inView:(UIView *)view
{
    _width = roundf(view.bounds.size.width * view.window.screen.scale);
    _height = roundf(view.bounds.size.height * view.window.screen.scale);

    _theView = view;

    _currentData = [NSMutableData new];
    _loadingImageSource = CGImageSourceCreateIncremental(NULL);

    [self fulfil:loadingImage];

    return self;
}

- (void)dealloc
{
    _image = nil;

    CFRelease(_loadingImageSource);
}

- (void)fulfil:(id)image
{
    _image = image;

    if ([_theView respondsToSelector:@selector(image)]) {
        [self->_theView setValue:nil forKey:@"image"];
        [self->_theView setValue:_image forKey:@"image"];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_currentData appendData:data];

    CGImageSourceUpdateData(_loadingImageSource, (__bridge CFDataRef) _currentData, NO);

    NSDictionary *options = @{
        (__bridge NSString *) (kCGImageSourceShouldCache) : @NO,
        (__bridge NSString *) (kCGImageSourceThumbnailMaxPixelSize) : @(fmax(_width, _height)),
        (__bridge NSString *) (kCGImageSourceCreateThumbnailFromImageIfAbsent) : @YES,
        (__bridge NSString *) (kCGImageSourceCreateThumbnailWithTransform) : @YES
    };

    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(_loadingImageSource, 0, (__bridge CFDictionaryRef) options);

    [self fulfil:[UIImage imageWithCGImage:imageRef]];

    CGImageRelease(imageRef);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CGImageSourceUpdateData(_loadingImageSource, (__bridge CFDataRef) _currentData, YES);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_loadingImageSource, 0, NULL);
    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];

    if (uiImage.size.width > _width || uiImage.size.height > _height) {
        CGRect scaledRect = CGRectMake(0, 0, _width, _height);
        CGFloat aspectRatio = uiImage.size.width / uiImage.size.height;

        scaledRect.size.width *= 1.0 / fminf(1.0, aspectRatio);
        scaledRect.size.height *= 1.0 / fmaxf(1.0, aspectRatio);

        UIGraphicsBeginImageContext(scaledRect.size);
        [uiImage drawInRect:scaledRect];

        uiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    [self fulfil:uiImage];

    CGImageRelease(imageRef);
}

@end

@implementation INVImageLoader

+ (NSURLConnection *)imageWithContentsOfURLRequest:(NSURLRequest *)request
                                  withLoadingImage:(UIImage *)loadingImage
                                            inView:(UIView *)theView
{
    INVLoadingImageProxy *proxy = [[INVLoadingImageProxy alloc] initWithLoadingImage:loadingImage inView:theView];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:proxy];
    [connection start];

    return connection;
}

@end
