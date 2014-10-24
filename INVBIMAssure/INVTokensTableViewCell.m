//
//  INVTokensTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVTokensTableViewCell.h"

@interface INVTokensTableViewCell() <VENTokenFieldDelegate, VENTokenFieldDataSource>
@property (readwrite, nonatomic) NSMutableArray *tokens;

@end

@implementation INVTokensTableViewCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.tokenField.dataSource = self;
    self.tokenField.delegate = self;
    self.tokenField.placeholderText = NSLocalizedString(@"ENTER_EMAILS:", nil);
    self.tokens = [[NSMutableArray alloc]initWithCapacity:0];

}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.tokenField becomeFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)collapse
{
    [self.tokenField collapse];
}

-(void)resignResponder
{
    [self.tokenField endEditing:YES];
    [self.tokenField resignFirstResponder];
}



#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [self.tokens addObject:text];
    [self.tokenField reloadData];
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(tokensChanged:)]) {
        [self.cellDelegate tokensChanged:self.tokens];
    }
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.tokens removeObjectAtIndex:index];
    [self.tokenField reloadData];
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(tokensChanged:)]) {
        [self.cellDelegate tokensChanged:self.tokens];
    }
}


#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.tokens[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.tokens count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return  [NSString stringWithFormat:@"%d",self.tokens.count ];
}

@end
