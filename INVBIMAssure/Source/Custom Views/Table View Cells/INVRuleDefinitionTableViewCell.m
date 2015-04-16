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
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    INVRuleDescriptorResourceDescription* resourceDetails = [self.ruleDefinition.descriptor descriptionDetailsForLanguageCode:languageCode];
    
    self.ruleDescriptionLabel.text = resourceDetails.shortDescription;
    
    
    if (self.checked) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
       // self.accessoryView = [[UIImageView alloc]initWithImage:[self _selectedImage]];
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
       // self.accessoryView = [[UIImageView alloc]initWithImage:[self _deselectedImage]];
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

#pragma mark - helpers

- (UIImage *)_selectedImage
{
    static UIImage *selectedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FAKFontAwesome *selectedIcon = [FAKFontAwesome checkCircleIconWithSize:30];
        [selectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        selectedImage = [selectedIcon imageWithSize:CGSizeMake(30, 30)];
    });
    
    return selectedImage;
}

- (UIImage *)_deselectedImage
{
    static UIImage *deselectedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FAKFontAwesome *deselectedIcon = [FAKFontAwesome circleOIconWithSize:30];
        [deselectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        
        deselectedImage = [deselectedIcon imageWithSize:CGSizeMake(30, 30)];
    });
    
    return deselectedImage;
}

@end
