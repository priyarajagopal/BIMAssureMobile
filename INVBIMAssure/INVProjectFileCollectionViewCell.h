//
//  INVProjectFileCollectionViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol INVProjectFileCollectionViewCellDelegate <NSObject>

-(void)onViewProjectFile;
-(void)onManageRuleSetsForProjectFile;

@end

@interface INVProjectFileCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak) id<INVProjectFileCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIImageView *fileThumbnail;
- (IBAction)onViewProjectSelected:(id)sender;
- (IBAction)onManageRuleSetsSelected:(UIBarButtonItem *)sender;


@end
