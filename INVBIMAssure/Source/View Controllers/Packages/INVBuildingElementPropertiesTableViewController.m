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

    NSDictionary* valueObj = self.property[@"source_value"] ?: self.property[@"value"];
    id unit = self.property[@"source_unit"] ?: self.property[@"unit"];

    id value = [self valueOfProperty:valueObj];
            
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


#pragma mark -helper
-(id)valueOfProperty:(NSDictionary*)valueObj {
    if ([valueObj.allKeys containsObject:@"as_string"]) {
        return valueObj[@"as_string"];
    }
    if ([valueObj.allKeys containsObject:@"as_float"]) {
        return valueObj[@"as_float"];
    }
    if ([valueObj.allKeys containsObject:@"as_integer"]) {
        return valueObj[@"as_integer"];
    }
    if ([valueObj.allKeys containsObject:@"as_long"]) {
        return valueObj[@"as_long"];
    }
    if ([valueObj.allKeys containsObject:@"as_double"]) {
        return valueObj[@"as_string"];
    }
    if ([valueObj.allKeys containsObject:@"as_boolean"]) {
        return valueObj[@"as_boolean"];
    }
    if ([valueObj.allKeys containsObject:@"as_date"]) {
        return valueObj[@"as_date"];
    }
    
    return nil;
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
                                            [[result valueForKeyPath:@"hits._source.properties"]firstObject];
                                         [self.tableView reloadData];
                                     }];
}


@end
