//
//  INVTokensTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VENTokenField/VENTokenField.h>
@protocol INVTokensTableViewCellDelegate <NSObject>

@required
-(void)tokensChanged:(NSArray*)tokens;
@end

@interface INVTokensTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet VENTokenField *tokenField;
@property (weak, nonatomic) id<INVTokensTableViewCellDelegate> cellDelegate;

- (void)collapse;
-(void)resignResponder;
@end
