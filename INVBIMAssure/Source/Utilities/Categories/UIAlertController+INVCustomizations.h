//
//  UIAlertController+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@interface UIAlertController (INVCustomizations)
- (instancetype)initWithErrorMessage:(NSString *)errorMesg, ... NS_FORMAT_FUNCTION(1, 2);
- (instancetype)initForImageSelectionWithHandler:(void (^)(UIImage *))handler;

@end
