//
//  INVModelTreeNodeTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeNodeTableViewCell.h"

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
        self.expandedIndicator.hidden = (self.indentationLevel > 0);

        self.detailsButton.hidden = (self.indentationLevel == 0);

        if (self.indentationLevel == 0) {
            [self.detailsButton addConstraint:self.collapseDetailsButtonConstraint];
        }
        else {
            [self.detailsButton removeConstraint:self.collapseDetailsButtonConstraint];
        }
    }
}

@end