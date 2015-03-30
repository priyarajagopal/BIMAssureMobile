//
//  INVRuleInstanceArrayParamTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/30/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceArrayParamTableViewCell.h"

#import <VENTokenField/VENTokenField.h>

@interface INVRuleInstanceArrayParamTableViewCell () <VENTokenFieldDataSource, VENTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet VENTokenField *ruleInstanceValue;

@property (strong) NSMutableArray *tokens;

@end

@implementation INVRuleInstanceArrayParamTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.ruleInstanceValue.maxHeight =
        self.contentView.bounds.size.height - (self.contentView.layoutMargins.top + self.contentView.layoutMargins.bottom);
    self.ruleInstanceValue.verticalInset = 0;
    self.ruleInstanceValue.placeholderText = nil;
    self.ruleInstanceValue.toLabelText = nil;

    self.tokens = [NSMutableArray new];

    [self updateUI];
}

#pragma mark - Content Management

- (void)updateUI
{
    self.ruleInstanceKey.text = self.actualParamDictionary[INVActualParamDisplayName];
    [self.tokens removeAllObjects];
    [self.tokens addObjectsFromArray:self.actualParamDictionary[INVActualParamValue]];

    [self.ruleInstanceValue reloadData];
}

#pragma mark - VENTokenFieldDataSource

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return self.tokens.count;
}

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.tokens[index];
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.tokens removeObjectAtIndex:index];

    self.actualParamDictionary[INVActualParamValue] = [self.tokens copy];

    [self.ruleInstanceValue reloadData];
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [self.tokens addObject:text];

    self.actualParamDictionary[INVActualParamValue] = [self.tokens copy];

    [self.ruleInstanceValue reloadData];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%ld", (unsigned long) [self numberOfTokensInTokenField:tokenField]];
}

@end
