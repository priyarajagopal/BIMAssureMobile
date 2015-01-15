//
//  NSTimeIntervalToString.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

NSString *NSTimeIntervalToStringAsAgo(NSTimeInterval timeInterval) {
    if (timeInterval <= 0) {
        return NSLocalizedString(@"AGO_JUST_NOW", nil);
    }
    
    if (timeInterval <= (60)) {
        NSInteger seconds = (NSInteger) (timeInterval);
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_SECONDS", nil), seconds];
    }
    
    if (timeInterval <= (60 * 60)) {
        NSInteger minutes = (NSInteger) (timeInterval / (60));
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_MINUTES", nil), minutes];
    }
    
    if (timeInterval <= (60 * 60 * 24)) {
        NSInteger hours = (NSInteger) (timeInterval / (60 * 60));
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_HOURS", nil), hours];
    }
    
    if (timeInterval <= (60 * 60 * 24 * 7)) {
        NSInteger days = (NSInteger) (timeInterval / (60 * 60 * 24));
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_DAYS", nil), days];
    }
    
    if (timeInterval <= (60 * 60 * 24 * 7 * 30)) {
        NSInteger weeks = (NSInteger) (timeInterval / (60 * 60 * 24 * 7));
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_WEEKS", nil), weeks];
    }
    
    if (timeInterval <= (60 * 60 * 24 * 7 * 30 * 12)) {
        NSInteger months = (NSInteger) (timeInterval / (60 * 60 * 24 * 7 * 30));
        
        return [NSString stringWithFormat:NSLocalizedString(@"AGO_MONTHS", nil), months];
    }
    
    NSInteger years = (NSInteger) (timeInterval / (60 * 60 * 24 * 7 * 30 * 12));
    return [NSString stringWithFormat:NSLocalizedString(@"AGO_YEARS", nil), years];
}