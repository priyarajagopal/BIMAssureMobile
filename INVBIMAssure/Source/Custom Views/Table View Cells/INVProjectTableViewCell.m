//
//  INVProjectTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectTableViewCell.h"
#import "INVProjectsTableViewController.h"
#import "UILabel+INVCustomizations.h"
#import "UIFont+INVCustomizations.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface INVProjectTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;

@property (weak, nonatomic) IBOutlet UILabel *fileCount;
@property (weak, nonatomic) IBOutlet UILabel *userCount;
@property (strong, nonatomic) INVGlobalDataManager *globalDataManager;

@end

@implementation INVProjectTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.globalDataManager = [INVGlobalDataManager sharedInstance];

    UILongPressGestureRecognizer *gestureRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongTap:)];
    [self.thumbnailImageView addGestureRecognizer:gestureRecognizer];

    // Initialization code
    [self updateUI];
}

- (void)setProject:(INVProject *)project
{
    _project = project;

    [self updateUI];
}

+ (NSDateFormatter *)dateFormatterForCreationDate
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];

        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    });

    return dateFormatter;
}

- (void)updateUI
{
    if (self.project != nil) {
        self.name.text = self.project.name;
        [self.overviewLabel setText:self.project.overview
                        withDefault:@"DESCRIPTION_UNAVAILABLE"
                      andAttributes:@{NSFontAttributeName : self.overviewLabel.font.italicFont}];

        self.fileCount.text = [NSString stringWithFormat:@"\uf0c5 %d", [self.project.pkgCount intValue]];
        self.userCount.text = @"\uf0c0 0";

        NSString *createdOnStr = NSLocalizedString(@"CREATED_ON", nil);
        NSString *createdOnWithDateStr =
            [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"CREATED_ON", nil),
                      [[INVProjectTableViewCell dateFormatterForCreationDate] stringFromDate:self.project.createdAt]];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:createdOnWithDateStr];

        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor darkTextColor]
                           range:NSMakeRange(0, createdOnStr.length - 1)];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor lightGrayColor]
                           range:NSMakeRange(createdOnStr.length, createdOnWithDateStr.length - createdOnStr.length)];

        self.createdOnLabel.attributedText = attrString;

        NSMutableURLRequest *projThumbnail =
            [[self.globalDataManager.invServerClient requestToGetThumbnailImageForProject:self.project.projectId] mutableCopy];
        if ([self.globalDataManager isRecentlyEditedProject:self.project.projectId]) {
            [projThumbnail setCachePolicy:NSURLRequestReloadIgnoringCacheData];
            [self.globalDataManager removeFromRecentlyEditedProjectList:self.project.projectId];
        }
        __weak __typeof(self) weakSelf = self;

        [self.thumbnailImageView setImageWithURLRequest:projThumbnail
            placeholderImage:[UIImage imageNamed:@"ImageNotFound"]
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.thumbnailImageView.image = image;
                });

            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                INVLogError(@"Failed to download image for project %@ with error %@", self.project.projectId, error);
            }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    UIColor *cyanColor = [UIColor colorWithRed:194.0 / 255 green:224.0 / 255 blue:240.0 / 255 alpha:1.0];
    // Configure the view for the selected state
    UIView *bgColorView = [[UIView alloc] init];
    UIColor *ltBlueColor = cyanColor;

    [bgColorView setBackgroundColor:ltBlueColor];
    [self setSelectedBackgroundView:bgColorView];
}

#pragma mark - IBActions

- (IBAction)onProjectDeleted:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onProjectDeleted:)]) {
        [self.delegate onProjectDeleted:self];
    }
}

- (IBAction)onProjectEdited:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onProjectEdited:)]) {
        [self.delegate onProjectEdited:self];
    }
}

- (IBAction)_handleLongTap:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [[UIApplication sharedApplication] sendAction:@selector(selectThumbnail:) to:nil from:self forEvent:nil];
    }
}

@end
