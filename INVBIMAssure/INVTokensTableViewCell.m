//
//  INVTokensTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVTokensTableViewCell.h"
const static NSInteger BASELINE_HEIGHT = 50;

@interface INVTokensTableViewCell() <VENTokenFieldDelegate, VENTokenFieldDataSource>
@property (readwrite, nonatomic) NSMutableArray *tokens;

@end

@implementation INVTokensTableViewCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.tokenField.maxHeight = CGFLOAT_MAX;
    self.tokenField.dataSource = self;
    self.tokenField.delegate = self;
    self.tokenField.placeholderText = NSLocalizedString(@"ENTER_EMAILS:", nil);
    UIColor* cyanBlueColor = [UIColor colorWithRed:38.0/255 green:138.0/255 blue:171.0/255 alpha:1.0];
    [self.tokenField setColorScheme: cyanBlueColor];
    
    self.tokens = [[NSMutableArray alloc]initWithCapacity:0];
    [self.tokenField becomeFirstResponder];


}

-(void)layoutSubviews {
    [super layoutSubviews];
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
    __block BOOL isEmail = NO;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    [detector enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if ([result.URL.scheme isEqualToString:@"mailto"] && result.range.length == text.length) {
            isEmail = YES;
        }
    }];
    
    if (isEmail) {
        [self.tokens addObject:text];
        if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(tokensChanged:)]) {
            [self.cellDelegate tokensChanged:self.tokens];
        }
        
        [tokenField reloadData];
    } else {
        
    }
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.tokens removeObjectAtIndex:index];
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(tokensChanged:)]) {
        [self.cellDelegate tokensChanged:self.tokens];
    }
    [tokenField reloadData];
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
    return  [NSString stringWithFormat:@"%ld",self.tokens.count ];
}


#pragma mark - helpers
-(BOOL) heightOfTokenFieldChangedForTokenField:(VENTokenField*)tokenField {
    return YES;
}
@end
