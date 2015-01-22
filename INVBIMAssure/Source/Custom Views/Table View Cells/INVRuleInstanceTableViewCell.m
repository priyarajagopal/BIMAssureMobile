//
//  INVRuleInstanceTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewCell.h"

/****
 Note : With iOS8, we can have action buttons supported natively on tabl;e view cell. The only reason we are doing this the hard way is to allow for the (unlikely) possibility that we may need to deploy < iOS8
 ***/
const static NSInteger DEFAULT_BOUNCE_VALUE = 10;
const static NSInteger DEFAULT_LEADING_SPACE = -8;

@interface INVRuleInstanceTableViewCell ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *editRuleButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteRuleButton;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *ruleContentView;

- (IBAction)onActionButtonTapped:(UIButton *)sender;

@end

@implementation INVRuleInstanceTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.ruleContentView addGestureRecognizer:self.panRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)openCell {
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

#pragma mark - UIEvents
- (IBAction)onActionButtonTapped:(UIButton *)sender {
    if (sender == self.editRuleButton) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onViewRuleTappedFor:)]) {
            [self.actionDelegate onViewRuleTappedFor:self];
        }
    }
    else if (sender == self.deleteRuleButton) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onDeleteRuleTappedFor:)]) {
            [self.actionDelegate onDeleteRuleTappedFor:self];
        }
    }
}


#pragma mark - UIPanGestureRecognizer
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.ruleContentView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.ruleContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == DEFAULT_LEADING_SPACE) {
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, DEFAULT_LEADING_SPACE);
                    if (constant == DEFAULT_LEADING_SPACE) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, DEFAULT_LEADING_SPACE);
                    if (constant == DEFAULT_LEADING_SPACE) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
        
        self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
        }
            
    
        break;
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == DEFAULT_LEADING_SPACE) {
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.editRuleButton.frame) / 2;
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat halfOfButtonOne = CGRectGetWidth(self.editRuleButton.frame) / 2;
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == DEFAULT_LEADING_SPACE) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}


#pragma mark - helpers
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.deleteRuleButton.frame) + (DEFAULT_LEADING_SPACE);
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate
{
    if (notifyDelegate && self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(cellDidClose:)]) {
        [self.stateDelegate cellDidClose:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == DEFAULT_LEADING_SPACE &&
        self.contentViewRightConstraint.constant == DEFAULT_LEADING_SPACE) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -DEFAULT_BOUNCE_VALUE;
    self.contentViewLeftConstraint.constant = DEFAULT_BOUNCE_VALUE;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = DEFAULT_LEADING_SPACE;
        self.contentViewLeftConstraint.constant = DEFAULT_LEADING_SPACE;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    if (notifyDelegate && self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(cellDidOpen:)]) {
        [self.stateDelegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }

    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - DEFAULT_BOUNCE_VALUE +(DEFAULT_LEADING_SPACE);
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + DEFAULT_BOUNCE_VALUE +(DEFAULT_LEADING_SPACE);
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
   
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
       
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



@end
