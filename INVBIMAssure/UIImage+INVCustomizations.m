//
//  UIImage+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "UIImage+INVCustomizations.h"

@implementation UIImage (INVCustomizations)
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
