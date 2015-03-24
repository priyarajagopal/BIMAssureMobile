//
//  INVRuleInstanceOverviewTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/19/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceOverviewTableViewCell.h"
#import "NSObject+INVCustomizations.h"

@interface INVRuleInstanceOverviewTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *ruleDescription;

@end

@implementation INVRuleInstanceOverviewTableViewCell

- (void)awakeFromNib
{
    [self.ruleDescription setTintColor:[UIColor darkGrayColor]];
}

- (BOOL)becomeFirstResponder
{
    return [self.ruleDescription becomeFirstResponder];
}

- (void)setOverview:(NSString *)overview
{
    self.ruleDescription.text = [overview copy];
}

- (NSString *)overview
{
    return self.ruleDescription.text;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }

    return YES;
}

@end
