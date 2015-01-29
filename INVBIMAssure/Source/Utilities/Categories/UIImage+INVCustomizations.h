//
//  UIImage+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (INVCustomizations)

+ (NSArray *)imagesInFolderNamed:(NSString *)folderName;
+ (NSArray *)imagesInFolderNamed:(NSString *)folderName recursive:(BOOL)recursive;

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize;
@end
