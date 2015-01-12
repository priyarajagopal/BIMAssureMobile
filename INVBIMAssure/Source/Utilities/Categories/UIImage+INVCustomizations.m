//
//  UIImage+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "UIImage+INVCustomizations.h"

@implementation UIImage (INVCustomizations)

+(NSArray *) imagesInFolderNamed:(NSString *)folderName {
    return [self imagesInFolderNamed:folderName recursive:NO];
}

+(NSArray *) imagesInFolderNamed:(NSString *)folderName recursive:(BOOL)recursive {
    NSMutableArray *results = [NSMutableArray new];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *folderURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:folderName];
    
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsHiddenFiles;
    if (!recursive) {
        options |= NSDirectoryEnumerationSkipsSubdirectoryDescendants;
    }
    
    NSArray *files = [fileManager contentsOfDirectoryAtURL:folderURL
                                includingPropertiesForKeys:@[ NSURLIsRegularFileKey, NSURLIsReadableKey ]
                                                   options:options
                                                     error:nil];
    
    for (NSURL *file in files) {
        if (![file isFileURL]) continue;
        
        [results addObject:[UIImage imageWithContentsOfFile:[file path]]];
    }
    
    return [results copy];
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return newImage;
}

@end
