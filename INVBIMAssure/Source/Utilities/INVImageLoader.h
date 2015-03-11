//
//  INVImageLoader.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVImageLoader : NSObject

+ (NSURLConnection *)imageWithContentsOfURLRequest:(NSURLRequest *)request
                                  withLoadingImage:(UIImage *)loadingImage
                                            inView:(UIView *)theView;

@end
