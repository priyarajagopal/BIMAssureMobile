//
//  INVAnalysisTemplateOverviewTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVAnalysisTemplateOverviewTableViewCell;
@protocol INVAnalysisTemplateOverviewTableViewCellDelegate <NSObject>

@optional
-(void)onCellSelected:(INVAnalysisTemplateOverviewTableViewCell*)selectedCell;
-(void)onCellDeSelected:(INVAnalysisTemplateOverviewTableViewCell*)selectedCell;
@end

@interface INVAnalysisTemplateOverviewTableViewCell : UITableViewCell
@property (nonatomic) INVAnalysisTemplate* analysisTemplate;
@property (nonatomic) BOOL checked;
@property (nonatomic, weak)id <INVAnalysisTemplateOverviewTableViewCellDelegate> delegate;
@end
