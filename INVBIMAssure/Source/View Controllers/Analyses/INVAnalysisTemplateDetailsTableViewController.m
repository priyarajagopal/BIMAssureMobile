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
#import "INVAnalysisTemplateHeaderView.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;
static const NSInteger ROWINDEX_RECIPEOVERVIEW = 0;

@interface INVAnalysisTemplateDetailsTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) INVAnalysisTemplateDetails *analysisDetails;
@property (nonatomic, strong) NSMutableArray *actualParamsDisplayArray; // Array of INVActualParamKeyValuePair objects
@property (nonatomic, strong) INVRuleParameterParser *ruleParamParser;
@property (nonatomic, strong)
    NSMutableDictionary *showRecipeDetails; // a dictionary representing the expanded status of each of the recipes
@end

@implementation INVAnalysisTemplateDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.refreshControl = nil;
    self.ruleParamParser = [INVRuleParameterParser instance];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RecipeDescriptionCell"];

    UINib *recipe = [UINib nibWithNibName:@"INVRuleActualParamsDisplayTableViewCell" bundle:nil];
    [self.tableView registerNib:recipe forCellReuseIdentifier:@"RecipeActualParams"];

    UINib *header = [UINib nibWithNibName:@"INVAnalysisTemplateHeaderView" bundle:nil];
    [self.tableView registerNib:header forHeaderFooterViewReuseIdentifier:@"AnalysisTemplateHeader"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self fetchAnalysisTemplateDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - server side

- (void)fetchAnalysisTemplateDetails
{
    [self showLoadProgress];
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
   
    [self.globalDataManager.invServerClient
        getAnalysisTemplateDetailsForId:self.analysisTemplateId
                    withCompletionBlock:^(INVAnalysisTemplateDetails *response, INVEmpireMobileError *error) {
                        [self.hud hide:YES];
                        if (error) {
                            [self showLoadAlert];
                        }
                        else {
                            self.analysisDetails = response;
                            INVRuleDescriptorResourceDescription* resourceDetails = [self.analysisDetails descriptionDetailsForLanguageCode:languageCode];
                            

                            self.tableView.tableHeaderView = [self viewForTableHeader];
                            self.title = resourceDetails.name;
                            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                        }
                    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.analysisDetails ? self.analysisDetails.recipes.count : 0; // add 1 for the overview section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[section];
    BOOL isExpanded = [self.showRecipeDetails[recipe.name] boolValue];
    if (isExpanded) {
        return self.analysisDetails ? recipe.actualParameters.count + 1 : 0;
    }
    else {
        return self.analysisDetails ? 1 : 0;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[indexPath.section];

    if (indexPath.row == ROWINDEX_RECIPEOVERVIEW) {
        UITableViewCell *cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RecipeDescriptionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        NSDictionary* nameDict = recipe.name;
        cell.textLabel.text = nameDict[languageCode];
        NSDictionary* overviewDict = recipe.overview;
        cell.detailTextLabel.text = overviewDict[languageCode];
        return cell;
    }
    else {
        __block INVRuleActualParamsDisplayTableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"RecipeActualParams"];
        cell.valueField = @"";
        cell.nameField = @"";
        cell.textTintColor = [UIColor grayColor];
        [cell setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.globalDataManager.invServerClient
            getRuleDefinitionForRuleId:recipe.ruleDefinitionId
                   WithCompletionBlock:^(INVRule *rule, INVEmpireMobileError *error) {
                       INV_ALWAYS:
                           [self.hud hide:YES];

                       INV_SUCCESS : {
                           NSArray *actualParamsDisplayArray =
                               [self.ruleParamParser transformActualParamsToDisplayArray:recipe.actualParameters
                                                                              definition:rule];
                           NSArray *orderedActualParams =
                               [self.ruleParamParser orderFormalParamsInArray:actualParamsDisplayArray];

                           __block INVActualParamKeyValuePair actualParam = orderedActualParams[indexPath.row - 1];

                           if ([[actualParam[INVActualParamType] firstObject] isEqual:@(INVParameterTypeElementType)] &&
                               ![actualParam[INVActualParamName] isEqualToString:@""]) {
                               NSString *elementTypeId = actualParam[INVActualParamValue];

                               [self.globalDataManager.invServerClient
                                   fetchBATypeDisplayNameForCode:elementTypeId
                                             withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                                 if (!error) {
                                                     NSString *title = [[result
                                                         valueForKeyPath:
                                                             @"hits.@unionOfArrays.fields.name.display_en"] firstObject];
                                                     if (title) {
                                                         actualParam[INVActualParamValue] = title;
                                                         actualParam[INVActualParamName] = @"";
                                                         [cell setValueField:title];
                                                         [cell setNameField:actualParam[INVActualParamDisplayName]];
                                                     }
                                                 }

                                             }];
                           }

                           if (![[actualParam[INVActualParamType] firstObject] isEqual:@(INVParameterTypeElementType)]) {
                               [cell setNameField:actualParam[INVActualParamDisplayName]];
                               [cell setValueField:actualParam[INVActualParamValue]];
                           }
                       }

                       INV_ERROR:
                           INVLogError(@"%@", error);
                   }];

        return cell;
    }

    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisTemplateRecipe *recipe = self.analysisDetails.recipes[indexPath.section];

    if ([self.showRecipeDetails.allKeys containsObject:recipe.name]) {
        BOOL currValue = [self.showRecipeDetails[recipe.name] boolValue];
        self.showRecipeDetails[recipe.name] = [NSNumber numberWithBool:!currValue];
    }
    else {
        self.showRecipeDetails[recipe.name] = [NSNumber numberWithBool:YES];
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UIView *)viewForTableHeader
{
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
    INVAnalysisTemplateHeaderView *view =
        [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AnalysisTemplateHeader"];
    INVRuleDescriptorResourceDescription* resourceDetails = [self.analysisDetails descriptionDetailsForLanguageCode:languageCode];
    view.overviewLabel.text = resourceDetails.shortDescription;
    return view;
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
- (NSMutableArray *)actualParamsDisplayArray
{
    if (!_actualParamsDisplayArray) {
        _actualParamsDisplayArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _actualParamsDisplayArray;
}

- (NSMutableDictionary *)showRecipeDetails
{
    if (!_showRecipeDetails) {
        _showRecipeDetails = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _showRecipeDetails;
}

@end
