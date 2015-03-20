//
//  INVModelTreeNodeTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeNodeTableViewCell.h"

#import "UIFont+INVCustomizations.h"

@interface INVModelTreeNodeTableViewCell ()

@property (nonatomic) IBOutlet UIButton *detailsButton;
@property (nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) IBOutlet UILabel *expandedIndicator;

@property (nonatomic) IBOutlet NSLayoutConstraint *collapseDetailsButtonConstraint;

@end

@implementation INVModelTreeNodeTableViewCell

- (void)awakeFromNib
{
    [self updateUI];
}

- (void)setNode:(INVModelTreeNode *)node
{
    _node = node;

    [self updateUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];

    UIEdgeInsets margins = self.contentView.layoutMargins;
    margins.left = 8 + (self.indentationLevel * self.indentationWidth);

    self.contentView.layoutMargins = margins;
}

- (void)updateUI
{
    if ([self.node isKindOfClass:[NSNull class]]) {
        self.nameLabel.text = nil;
        self.expandedIndicator.hidden = YES;
        self.detailsButton.hidden = YES;
    }
    else {
        self.nameLabel.text = self.node.name;

        self.expandedIndicator.text = self.node.expanded ? @"\uf0d7" : @"\uf0da";
        self.expandedIndicator.hidden = self.node.isLeaf;

        self.detailsButton.hidden = !self.node.isLeaf;

        if (self.indentationLevel == 0) {
            self.nameLabel.font = [self.nameLabel.font fontWithTraits:UIFontDescriptorTraitBold];
        }
        else {
            self.nameLabel.font = [self.nameLabel.font fontWithTraits:0];
        }

        if (!self.node.isLeaf) {
            [self.detailsButton addConstraint:self.collapseDetailsButtonConstraint];
        }
        else {
            [self.detailsButton removeConstraint:self.collapseDetailsButtonConstraint];
        }
    }
}

@end