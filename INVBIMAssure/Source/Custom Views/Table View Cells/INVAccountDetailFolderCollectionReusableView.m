//
//  INVAccountDetailFolderCollectionReusableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAccountDetailFolderCollectionReusableView.h"

@interface INVAccountDetailFolderCollectionReusableView ()

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *desc;
@property (strong, nonatomic) UILabel *upc;
@property (strong, nonatomic) UIButton *button;

@end

@implementation INVAccountDetailFolderCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;

        self.title = [[UILabel alloc] init];
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.title.textColor = [UIColor colorWithRed:0x33 / 250.0 green:0x33 / 250.0 blue:0x33 / 250.0 alpha:1.0];
        self.title.text = @"Foo";

        self.desc = [[UILabel alloc] init];
        self.desc.numberOfLines = 0;
        self.desc.translatesAutoresizingMaskIntoConstraints = NO;
        self.desc.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.desc.textColor = [UIColor colorWithRed:0x33 / 250.0 green:0x33 / 250.0 blue:0x33 / 250.0 alpha:1.0];
        self.desc.text = @"Bar";

        self.upc = [[UILabel alloc] init];
        self.upc.translatesAutoresizingMaskIntoConstraints = NO;
        self.upc.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        self.upc.textColor = [UIColor colorWithRed:0x33 / 250.0 green:0x33 / 250.0 blue:0x33 / 250.0 alpha:1.0];

        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0, 0, 100, 44);
        self.button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.button setTitle:@"Which Item?" forState:UIControlStateNormal];

        [self addSubview:self.button];
        [self addSubview:self.title];
        [self addSubview:self.desc];
        [self addSubview:self.upc];

        NSMutableArray *constraintsArray = [NSMutableArray array];

        // title
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.title
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:20.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.title
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:10.0f]];

        //		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.title
        // attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight
        // multiplier:1.0 constant:-10.0f]];

        // button
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.button
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:14.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.button
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.title
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:10.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.button
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-10.0f]];

        // description
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.desc
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.title
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.desc
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.title
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.desc
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.title
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:5.0f]];

        // upc
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.upc
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.desc
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.upc
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.desc
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0.0f]];

        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.upc
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.desc
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:5.0f]];

        [self addConstraints:constraintsArray];
    }
    return self;
}

@end
