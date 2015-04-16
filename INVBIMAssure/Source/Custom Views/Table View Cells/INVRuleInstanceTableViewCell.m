//
//  INVRuleInstanceTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewCell.h"
#import "UILabel+INVCustomizations.h"
#import "UIFont+INVCustomizations.h"

@interface INVRuleInstanceTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) IBOutlet UILabel *overviewLabel;
@property (nonatomic) IBOutlet UILabel *ruleWarningLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *collapseRuleWarningConstraint;

@end

@implementation INVRuleInstanceTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (void)updateUI
{
    if (self.ruleInstance) {
        NSNumber* ruleDefId = self.ruleInstance.ruleDefId;
        [[INVGlobalDataManager sharedInstance].invServerClient getRuleDefinitionForRuleId:ruleDefId WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
            if (error) {
                [self configureRuleInstanceDetailsWithName:nil andDetails:nil];
            }
            else {
                INVRule* rule = result;
                NSString* languageCode = [[ NSLocale currentLocale]objectForKey:NSLocaleLanguageCode];
                INVRuleDescriptor* descriptor = rule.descriptor;
                INVRuleDescriptorResourceDescription* resource = [descriptor descriptionDetailsForLanguageCode:languageCode];
                if (resource) {
                    [self configureRuleInstanceDetailsWithName:resource.name andDetails:resource.longDescription];
                }
                else {
                    [self configureRuleInstanceDetailsWithName:nil andDetails:nil];
                }
                
                
            }
       
        }];
        
        if ([self.ruleInstance.emptyParamCount integerValue] > 0) {
            [self.ruleWarningLabel removeConstraint:self.collapseRuleWarningConstraint];
        }
        else {
            [self.ruleWarningLabel addConstraint:self.collapseRuleWarningConstraint];
        }
    }
}

- (void)setRuleInstance:(INVRuleInstance *)rule
{
    _ruleInstance = rule;

    [self updateUI];
}

#pragma mark - helpers
-(void) configureRuleInstanceDetailsWithName:(NSString*)name andDetails:(NSString*)details {
    [self.nameLabel setText:name
                withDefault:NSLocalizedString(@"RULE_NAME_UNAVAILABLE", nil)
              andAttributes:@{NSFontAttributeName : self.overviewLabel.font.italicFont}];
    
    [self.overviewLabel setText:details
                    withDefault:NSLocalizedString(@"RULE_OVERVIEW_UNAVAILABLE", nil)
                  andAttributes:@{NSFontAttributeName : self.overviewLabel.font.italicFont}];
    
}

@end
