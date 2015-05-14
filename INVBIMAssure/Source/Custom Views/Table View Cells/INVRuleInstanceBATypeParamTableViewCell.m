//
// INVRuleInstanceBAElementTypeParamTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceBATypeParamTableViewCell.h"

@interface INVRuleInstanceBATypeParamTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UIButton *ruleInstanceElementType;

@end

@implementation INVRuleInstanceBATypeParamTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateUI];
}

#pragma mark - Content Management

- (void)updateUI
{
    self.ruleInstanceKey.text = self.actualParamDictionary[INVActualParamDisplayName];

    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSString class]]) {
        [self.ruleInstanceElementType setTitle:nil forState:UIControlStateNormal];

        id code = self.actualParamDictionary[INVActualParamValue];
        [[INVGlobalDataManager sharedInstance].invServerClient
            fetchBATypeDisplayNameForCode:code
                      withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                          NSString *title = [[result valueForKeyPath:@"hits.@unionOfArrays.fields.name.display_en"] firstObject];

                          [self.ruleInstanceElementType setTitle:title forState:UIControlStateNormal];
                      }];
    }
    else {
        [self.ruleInstanceElementType setTitle:NSLocalizedString(@"SELECT_ELEMENT_TYPE", nil) forState:UIControlStateNormal];
    }
}
@end
