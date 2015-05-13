//
//  INVRuleDefinitionSelectionTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionSelectionTableViewController.h"
#import "INVRuleDefinitionsTableViewController.h"


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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRuleDefinitions"]) {
        /*
         self.ruleTypePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-150, CGRectGetWidth(self.view.frame), 150)];
         self.ruleTypePickerView.delegate = self;
         self.ruleTypePickerView.dataSource = self;
         [self.view addSubview:self.ruleTypePickerView];
         
         */
        INVRuleDefinitionsTableViewController *ruleDefinitionsVC = (INVRuleDefinitionsTableViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        ruleDefinitionsVC.analysisId = self.analysisId;
    }
    
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == INDEX_ROW_RULEDEFINITIONS) {
        [self.selectRuleDefinitionTransition perform:self];
    }
    else if (indexPath.row == INDEX_ROW_ANALYSISTEMPLATES) {
        
    }
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
