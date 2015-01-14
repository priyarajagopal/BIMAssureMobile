//
//  MBProgressHUD+INVBAHUD.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "MBProgressHUD+INVBAHUD.h"

@interface MBProgressHUD()
@end

@implementation MBProgressHUD (INVBAHUD)
+(MBProgressHUD*)loginUserHUD:(NSString*)extra {
    MBProgressHUD* hud = [[MBProgressHUD alloc]init];
    
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMode:MBProgressHUDModeIndeterminate];
    NSString* mesg  = extra? [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LOGGING_IN",nil),extra]:NSLocalizedString(@"LOGGING_IN",nil);
    [hud setLabelText:mesg];
    [hud setDimBackground:YES];
    [hud setRemoveFromSuperViewOnHide:YES];
    
    return hud;
}

+(MBProgressHUD*)loginAccountHUD:(NSString*)extra {
    MBProgressHUD* hud = [[MBProgressHUD alloc]init];
    
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMode:MBProgressHUDModeIndeterminate];
    NSString* mesg  = extra? [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LOGGING_IN_ACCOUNT",nil),extra]:NSLocalizedString(@"LOGGING_IN_ACCOUNT",nil);
    
    [hud setLabelText:mesg];
    [hud setDimBackground:YES];
    [hud setRemoveFromSuperViewOnHide:YES];
    
    return hud;
}

+(MBProgressHUD*)signupHUD:(NSString*)extra {
    MBProgressHUD* hud = [[MBProgressHUD alloc]init];
    
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMode:MBProgressHUDModeIndeterminate];
    NSString* mesg  = extra? [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"SIGNING_UP",nil),extra]:NSLocalizedString(@"SIGNING_UP",nil);
    
    [hud setLabelText:mesg];
    [hud setDimBackground:YES];
    [hud setRemoveFromSuperViewOnHide:YES];
    
    return hud;
}

+(MBProgressHUD*)loadingViewHUD:(NSString*)extra {
    MBProgressHUD* hud = [[MBProgressHUD alloc]init];
    
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMode:MBProgressHUDModeIndeterminate];
    NSString* mesg  = extra? [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LOADING_DATA",nil),extra]:NSLocalizedString(@"LOADING_DATA",nil);
    
    [hud setLabelText:mesg];
    [hud setDimBackground:NO];
    [hud setRemoveFromSuperViewOnHide:YES];
    
    return hud;
}

+(MBProgressHUD*)generalViewHUD:(NSString*)extra {
    MBProgressHUD* hud = [[MBProgressHUD alloc]init];
    
    [hud setAnimationType:MBProgressHUDAnimationFade];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    [hud setLabelText:extra];
    [hud setDimBackground:NO];
    [hud setRemoveFromSuperViewOnHide:YES];
    
    return hud;
}


@end
