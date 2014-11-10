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

-(void)onViewProjectFile:(INVProjectFileCollectionViewCell*)sender;
-(void)onManageRuleSetsForProjectFile:(INVProjectFileCollectionViewCell*)sender;

@end

@interface INVProjectFileCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak) id<INVProjectFileCollectionViewCellDelegate> delegate;
@property (nonatomic,strong)NSNumber* modelId;
@property (nonatomic,strong)NSNumber* fileId;
@property (weak, nonatomic) IBOutlet UILabel *fileName;

@property (weak, nonatomic) IBOutlet UIImageView *fileThumbnail;
- (IBAction)onViewProjectSelected:(UIBarButtonItem*)sender;
- (IBAction)onManageRuleSetsSelected:(UIBarButtonItem *)sender;


@end
