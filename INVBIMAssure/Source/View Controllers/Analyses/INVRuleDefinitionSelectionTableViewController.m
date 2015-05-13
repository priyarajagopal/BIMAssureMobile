//
//  INVRuleDefinitionSelectionTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionSelectionTableViewController.h"
#import "INVRuleDefinitionsTableViewController.h"
#import "INVAnalysisTemplatesTableViewController.h"


static const NSInteger INDEX_ROW_RULEDEFINITIONS = 0;
static const NSInteger INDEX_ROW_ANALYSISTEMPLATES = 1;



@interface INVRuleDefinitionSelectionTableViewController ()
@property (nonatomic,strong) IBOutlet INVTransitionToStoryboard *selectRuleDefinitionTransition;
@end

@implementation INVRuleDefinitionSelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRuleDefinitions"]) {

        INVRuleDefinitionsTableViewController *ruleDefinitionsVC = (INVRuleDefinitionsTableViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        ruleDefinitionsVC.analysisId = self.analysisId;
    }
    if ([[segue identifier] isEqualToString:@"ShowAnalysisTemplateSegue"]) {
        INVAnalysisTemplatesTableViewController *analysisTemplateVC = (INVAnalysisTemplatesTableViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        analysisTemplateVC.analysisId = self.analysisId;
    }
    
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == INDEX_ROW_RULEDEFINITIONS) {
        [self.selectRuleDefinitionTransition perform:self];
    }
    else if (indexPath.row == INDEX_ROW_ANALYSISTEMPLATES) {
        [self performSegueWithIdentifier:@"ShowAnalysisTemplateSegue" sender:self];
    }
    
}


@end
