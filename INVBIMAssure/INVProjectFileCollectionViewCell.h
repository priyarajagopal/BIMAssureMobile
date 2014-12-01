//
//  INVProjectFileCollectionViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVProjectFileCollectionViewCell;

@protocol INVProjectFileCollectionViewCellDelegate <NSObject>

@optional
-(void)onViewProjectFile:(INVProjectFileCollectionViewCell*)sender;
-(void)onManageRuleSetsForProjectFile:(INVProjectFileCollectionViewCell*)sender;
-(void)onRunRulesForProjectFile:(INVProjectFileCollectionViewCell*)sender;

@end

@interface INVProjectFileCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak) id<INVProjectFileCollectionViewCellDelegate> delegate;
@property (nonatomic,copy)NSNumber* modelId;
@property (nonatomic,copy)NSNumber* fileId;
@property (nonatomic,copy)NSNumber* fileVersionId;
@property (weak, nonatomic) IBOutlet UILabel *fileName;

@property (weak, nonatomic) IBOutlet UIImageView *fileThumbnail;
- (IBAction)onViewProjectSelected:(UIBarButtonItem*)sender;
- (IBAction)onManageRuleSetsSelected:(UIBarButtonItem *)sender;
- (IBAction)onRunRulesSelected:(UIBarButtonItem *)sender;

@end
