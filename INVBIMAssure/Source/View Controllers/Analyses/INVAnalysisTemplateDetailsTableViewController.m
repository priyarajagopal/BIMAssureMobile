//
//  INVAnalysisTemplateDetailsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/14/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTemplateDetailsTableViewController.h"
#import "INVRuleActualParamsDisplayTableViewCell.h"
#import "INVAnalysisTemplateOverviewTableViewCell.h"
#import "INVRuleParameterParser.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;
static const NSInteger SECTIONINDEX_TEMPLATEDESCRIPTION = 0;
static const NSInteger ROWINDEX_RECIPEOVERVIEW = 0;

@interface INVAnalysisTemplateDetailsTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) INVAnalysisTemplateDetails *analysisDetails;
@property (nonatomic, strong) NSMutableArray *actualParamsDisplayArray; // Array of INVActualParamKeyValuePair objects
@property (nonatomic, strong) INVRuleParameterParser *ruleParamParser;
@property (nonatomic, strong) NSMutableDictionary *showRecipeDetails; // a dictionary representing the expanded status of each of the recipes
@end

@implementation INVAnalysisTemplateDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.refreshControl = nil;
    self.ruleParamParser = [INVRuleParameterParser instance];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TemplateDescriptionCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RecipeDescriptionCell"];

    UINib *recipe = [UINib nibWithNibName:@"INVRuleActualParamsDisplayTableViewCell" bundle:nil];
    [self.tableView registerNib:recipe forCellReuseIdentifier:@"RecipeActualParams"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self fetchAnalysisTemplateDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchAnalysisTemplateDetails
{
    [self showLoadProgress];
    [self.globalDataManager.invServerClient
        getAnalysisTemplateDetailsForId:self.analysisTemplateId
                    withCompletionBlock:^(INVAnalysisTemplateDetails *response, INVEmpireMobileError *error) {
                        [self.hud hide:YES];
                        if (error) {
                            [self showLoadAlert];
                        }
                        else {
                            self.analysisDetails = response;
                            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                        }
                    }];
}

#pragma mark - UITableViewDatSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.analysisDetails ? self.analysisDetails.recipes.count + 1 : 0; // add 1 for the overview section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTIONINDEX_TEMPLATEDESCRIPTION) {
        return self.analysisDetails ? 1 : 0;
    }
    else {
        INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[section - 1];
        BOOL isExpanded = [self.showRecipeDetails[recipe.name] boolValue];
        if (isExpanded) {
            return self.analysisDetails ? recipe.actualParameters.count + 1 : 0;
        }
        else {
            return self.analysisDetails ? 1 : 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTIONINDEX_TEMPLATEDESCRIPTION) {
        UITableViewCell *cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TemplateDescriptionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.text = self.analysisDetails.name;
        cell.detailTextLabel.text = self.analysisDetails.overview;
        return cell;
    }
    else {
        INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[indexPath.section - 1];

        if (indexPath.row == ROWINDEX_RECIPEOVERVIEW) {
            UITableViewCell *cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RecipeDescriptionCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.text = recipe.name;
            cell.detailTextLabel.text = recipe.overview;
            return cell;
        }
        else {
            NSArray* actualParamsDisplayArray = [[self.ruleParamParser transformActualParamDictionaryToArray:recipe.actualParameters]mutableCopy];
            INVActualParamKeyValuePair actualParam = actualParamsDisplayArray[indexPath.row-1];

            INVRuleActualParamsDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeActualParams"];
            cell.textTintColor = [UIColor grayColor];
            [cell setUserInteractionEnabled:NO];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.actualParamDictionary = actualParam;
            return cell;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[indexPath.section - 1];

    if (indexPath.section == SECTIONINDEX_TEMPLATEDESCRIPTION) {
        return;
    }

    if ([self.showRecipeDetails.allKeys containsObject:recipe.name]) {
        BOOL currValue = [self.showRecipeDetails[recipe.name] boolValue];
        self.showRecipeDetails[recipe.name] = [NSNumber numberWithBool:!currValue];
    }
    else {
        self.showRecipeDetails[recipe.name] = [NSNumber numberWithBool:YES];
    }

    [self.tableView reloadData];
    //   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section - 1]
    //               withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - helpers

- (void)showLoadAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"ACCOUNT_UPDATE_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

#pragma mark - accessors
-(NSMutableArray*)actualParamsDisplayArray {
    if (!_actualParamsDisplayArray) {
        _actualParamsDisplayArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _actualParamsDisplayArray;
}

-(NSMutableDictionary*)showRecipeDetails {
    if (!_showRecipeDetails) {
        _showRecipeDetails = [[NSMutableDictionary alloc]initWithCapacity:0];
    }
    return _showRecipeDetails;
}

@end
