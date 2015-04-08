//
//  INVRuleActualParamsDisplayTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 4/8/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleActualParamsDisplayTableViewCell.h"

@interface INVRuleActualParamsDisplayTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKeyLabel;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValueTextField;
@property (readonly, nonatomic)NSString* valueString;

@end
@implementation INVRuleActualParamsDisplayTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updateUI];
}

- (void)updateUI
{
    self.ruleInstanceKeyLabel.text = self.actualParamDictionary[INVActualParamDisplayName];
    self.ruleInstanceValueTextField.text = self.valueString;
    
    [self.ruleInstanceValueTextField setTextColor:[UIColor whiteColor]];
    [self setNeedsLayout];
}

- (void)setActualParamDictionary:(INVActualParamKeyValuePair)actualParamDictionary
{
    _actualParamDictionary = actualParamDictionary;
    
    [self updateUI];
}


#pragma mark accessors
- (NSString *)valueString
{
    id value = self.actualParamDictionary[INVActualParamValue];
    
    if (value == nil || [value isKindOfClass:[NSNull class]])
        return @"";
    
    if ([value isKindOfClass:[NSString class]])
        return value;
    
    if ([value isKindOfClass:[NSNumber class]])
        return [value stringValue];
    
    if ([value isKindOfClass:[NSDate class]]) {
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [NSDateFormatter new];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
        });
        
        return [dateFormatter stringFromDate:value];
    }
    
    [NSException raise:NSInvalidArgumentException format:@"Unknown class of value %@", value];
    
    return value;
}
@end
