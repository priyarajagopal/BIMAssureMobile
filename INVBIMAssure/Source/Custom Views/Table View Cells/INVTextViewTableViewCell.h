//
//  INVTextViewTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol INVTextViewTableViewCellDelegate<NSObject>

@optional
- (void)cellSizeChanged:(CGSize)size withTextString:(NSString *)textStr;
@end

@interface INVTextViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) id<INVTextViewTableViewCellDelegate> cellDelegate;

@end
