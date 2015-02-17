//
//  INVProjectTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectTableViewCell.h"

@interface INVProjectTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UILabel *fileCount;
@property (weak, nonatomic) IBOutlet UILabel *userCount;

@end

@implementation INVProjectTableViewCell

- (void)awakeFromNib
{
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

        [[INVGlobalDataManager sharedInstance].invServerClient
            getTotalCountOfPkgMastersForProject:self.project.projectId
                            WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                if (error)
                                    return;

                                self.fileCount.text = [NSString stringWithFormat:@"\uf0c5 %d", [result intValue]];
                            }];

        // TODO: Load this from a cache first?
        self.fileCount.text = @"\uf0c5 0";
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

        self.thumbnailImageView.image = nil;
        [MBProgressHUD showHUDAddedTo:self.thumbnailImageView animated:YES];

        [[INVGlobalDataManager sharedInstance].invServerClient
            getThumbnailImageForProject:self.project.projectId
                  withCompletionHandler:^(id result, INVEmpireMobileError *error) {
                      [MBProgressHUD hideHUDForView:self.thumbnailImageView animated:YES];

                      if (error) {
                          INVLogError(@"%@", error);
                          return;
                      }

                      self.thumbnailImageView.image = result;
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

@end
