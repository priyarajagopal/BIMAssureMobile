//
//  INVRuleDefinitionTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/26/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionTableViewCell.h"

@interface INVRuleDefinitionTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *ruleDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkmarkLabel;

@end

@implementation INVRuleDefinitionTableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    [self updateUI];
}

-(void) updateUI {
    self.ruleDescriptionLabel.text = self.ruleDefinition.overview;
    
    if (self.checked) {
        self.checkmarkLabel.text = @"\uf05d";
    } else {
        self.checkmarkLabel.text = @"\uf10c";
    }
}

-(void) setRuleDefinition:(INVRule *)ruleDefinition {
    _ruleDefinition = ruleDefinition;
    
    [self updateUI];
}

-(void) setChecked:(BOOL)checked {
    _checked = checked;
    
    [self updateUI];
}

@end
