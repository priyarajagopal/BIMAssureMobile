//
//  INVAnalysisTemplateDetailsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/14/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTemplateDetailsTableViewController.h"
#import "INVRuleActualParamsDisplayTableViewCell.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVAnalysisTemplateDetailsTableViewController ()

@end

@implementation INVAnalysisTemplateDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RuleDescriptionCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TemplateDescriptionCell"];
    
    UINib *recipes = [UINib nibWithNibName:@"INVRuleActualParamsDisplayTableViewCell" bundle:nil];

    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self fetchAnalysisTemplateDetails];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)fetchAnalysisTemplateDetails {
    
}
@end
