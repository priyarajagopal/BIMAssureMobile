//
//  MBProgressHUD+INVBAHUD.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (INVBAHUD)

+(MBProgressHUD*)loginUserHUD:(NSString*)extra;
+(MBProgressHUD*)loginAccountHUD:(NSString*)extra;
+(MBProgressHUD*)loadingViewHUD:(NSString*)extra;

@end
