//
//  INVModelTreeNodePropertiesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVBuildingElementPropertiesTableViewController.h"

@interface INVBuildingElementPropertiesTableViewCell : UITableViewCell

@property IBOutlet UILabel *propertyNameLabel;
@property IBOutlet UILabel *propertyValueLabel;

@property (nonatomic, copy) NSDictionary *property ;

@end

@implementation INVBuildingElementPropertiesTableViewCell

- (void)setProperty:(NSDictionary *)property
{
    _property = property;

    [self updateUI];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateUI];
}

- (void)updateUI
{
    self.propertyNameLabel.text = self.property[@"display"];

    id value = self.property[@"source_value"] ?: self.property[@"value"];
    id unit = self.property[@"source_unit"] ?: self.property[@"unit"];

    if (!value) {
        self.propertyValueLabel.text = NSLocalizedString(@"VALUE_MISSING", nil);
        self.propertyValueLabel.textColor = [UIColor redColor];

        return;
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setUsesSignificantDigits:YES];
        [numberFormatter setMaximumSignificantDigits:6];

        value = [numberFormatter stringFromNumber:value];
    }

    self.propertyValueLabel.text = [value stringByAppendingString:unit ?: @""];
    self.propertyValueLabel.textColor = [UIColor whiteColor];
}

@end

@interface INVBuildingElementPropertiesTableViewController ()

@property (nonatomic, copy) NSArray *elementProperties;

@end

@implementation INVBuildingElementPropertiesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
    self.navigationItem.title = self.buildingElementName;

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;

    [self fetchListOfProperties];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elementProperties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVBuildingElementPropertiesTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"propertyCell" forIndexPath:indexPath];

    cell.property = self.elementProperties[indexPath.row];

    return cell;
}

#pragma mark - Server Side

- (void)fetchListOfProperties
{
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
        fetchBuildingElementPropertiesOfSpecifiedElement:self.buildingElementId
                                     ForPackageVersionId:self.packageVersionId
                                              fromOffset:nil
                                                withSize:nil
                                     withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                         [hud hide:YES];

                                         self.elementProperties =
                                             [[[result valueForKeyPath:@"hits._source.intrinsics"] firstObject] allValues];
                                         [self.tableView reloadData];
                                     }];
}
@end
