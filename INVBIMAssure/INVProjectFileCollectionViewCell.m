//
//  INVProjectFileCollectionViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileCollectionViewCell.h"

@implementation INVProjectFileCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


#pragma mark - UIEvent handlers
- (IBAction)onViewProjectSelected:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onViewProjectFile)]) {
        [self.delegate onViewProjectFile];
    }

}

- (IBAction)onManageRuleSetsSelected:(UIBarButtonItem *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onManageRuleSetsForProjectFile)]) {
        [self.delegate onManageRuleSetsForProjectFile];
    }

}
@end
