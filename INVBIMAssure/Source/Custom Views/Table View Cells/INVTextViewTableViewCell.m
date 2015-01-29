//
//  INVTextViewTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVTextViewTableViewCell.h"

static NSInteger BASELINE_HEIGHT = 200;
@interface INVTextViewTableViewCell () <UITextViewDelegate>
@property (nonatomic, assign) NSInteger currentHeight;
@end

@implementation INVTextViewTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.textView.delegate = self;
    self.currentHeight = BASELINE_HEIGHT;
    self.textView.tintColor = [UIColor darkTextColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    INVLogDebug();
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    INVLogDebug();
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView;
{
    CGFloat height =
        BASELINE_HEIGHT >= textView.contentSize.height ? BASELINE_HEIGHT : textView.contentSize.height + 10; // 10 buffer

    if ((height != self.currentHeight) && [self.cellDelegate respondsToSelector:@selector(cellSizeChanged:withTextString:)]) {
        [self.cellDelegate cellSizeChanged:CGSizeMake(self.bounds.size.width, height) withTextString:textView.text];
    }
    self.currentHeight = height;
}

@end
