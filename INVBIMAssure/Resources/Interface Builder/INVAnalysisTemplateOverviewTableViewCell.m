//
//  INVAnalysisTemplateOverviewTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTemplateOverviewTableViewCell.h"

@interface INVAnalysisTemplateOverviewTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UIButton* selectedButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation INVAnalysisTemplateOverviewTableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    [self updateUI];
}


-(void) updateUI {
    
    self.overviewLabel.text = self.analysisTemplate.overview;
    self.nameLabel.text = self.analysisTemplate.name;
    
    if (self.checked) {
        [self.selectedButton setImage:[self _selectedImage] forState:UIControlStateNormal];
        //self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        [self.selectedButton setImage:[self _deselectedImage] forState:UIControlStateNormal];
        //self.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(void) setAnalysisTemplate:(INVAnalysisTemplate *)analysisTemplate{
    _analysisTemplate = analysisTemplate;
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
        UIColor *cyanBlueColor = [UIColor colorWithRed:38.0 / 255 green:145.0 / 255 blue:191.0 / 255 alpha:1.0];

        [selectedIcon setAttributes:@{NSForegroundColorAttributeName : cyanBlueColor}];
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

#pragma mark - IBAction
-(IBAction)onItemSelected:(UIButton*)sender {
    self.checked = !self.checked;
       [self updateUI];
    if (self.checked && self.delegate && [self.delegate respondsToSelector:@selector(onCellSelected:)]) {
        [self.delegate performSelector:@selector(onCellSelected:) withObject:self];
    }
    else if (!self.checked && self.delegate && [self.delegate respondsToSelector:@selector(onCellDeSelected:)]) {
        [self.delegate performSelector:@selector(onCellDeSelected:) withObject:self];
    }
 
}

@end