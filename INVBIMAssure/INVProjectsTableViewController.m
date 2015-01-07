//
//  INVProjectsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectsTableViewController.h"
#import "INVProjectTableViewCell.h"
#import "INVProjectDetailsTabViewController.h"
#import "INVProjectFilesListViewController.h"
#import "INVProjectEditViewController.h"
#import "INVRulesListViewController.h"
#import "INVProjectListSplitViewController.h"
#import "INVRuleExecutionsTableViewController.h"
#import "UIImage+INVCustomizations.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 300;
static const NSInteger TABINDEX_PROJECT_FILES = 0;
static const NSInteger TABINDEX_PROJECT_RULESETS = 1;
//static const NSInteger TABINDEX_PROJECT_RULEEXECUTIONS = 2;

@interface INVProjectsTableViewController ()<INVProjectTableViewCellDelegate, INVProjectEditViewControllerDelegate>
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic,strong)INVProjectDetailsTabViewController* projectDetailsController;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;

@end

@implementation INVProjectsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"PROJECTS", nil);
   
    self.clearsSelectionOnViewWillAppear = NO;
    
    UINib* nib = [UINib nibWithNibName:@"INVProjectTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ProjectCell"];
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.dataSource = self.dataSource;
    [self fetchProjectList];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.projectManager = nil;
    self.dateFormatter = nil;
    self.projectDetailsController = nil;
}

-(void)onRefreshControlSelected:(id)event {
    [self fetchProjectList];
}



#pragma mark - server side
-(void)fetchProjectList {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllProjectsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        if (!error) {
#pragma note Yes - you could have directly accessed accounts from accountManager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                 [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            else {
                UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PROJECTS_LOAD", nil),dbError.code]];
                [self presentViewController:errController animated:YES completion:^{
                    
                }];
            }
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PROJECTS_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];

        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ProjectDetailSegue" sender:self];
}


 #pragma mark - Navigation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     if ([segue.identifier isEqual:@"ProjectDetailSegue"]) {
         INVProject* project = [self.dataResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
         
         INVProjectListSplitViewController* projectsSplitViewController = (INVProjectListSplitViewController*)self.splitViewController;
         projectsSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
         
         INVProjectDetailsTabViewController* projectDetailsController = (INVProjectDetailsTabViewController*)segue.destinationViewController;

         UINavigationController* navController = projectDetailsController.viewControllers[TABINDEX_PROJECT_FILES];
         INVProjectFilesListViewController* fileListController = (INVProjectFilesListViewController*) navController.topViewController;
    
         fileListController.projectId = project.projectId;
         
         UINavigationController* rsNavController = projectDetailsController.viewControllers[TABINDEX_PROJECT_RULESETS];;
         INVRulesListViewController* ruleSetController = (INVRulesListViewController*) rsNavController.topViewController;
          
         ruleSetController.projectId = project.projectId;
     }
     
     if ([segue.identifier isEqualToString:@"editProject"]) {
         UINavigationController *editNavigationController = [segue destinationViewController];
         INVProjectEditViewController *editViewController = [[editNavigationController viewControllers] firstObject];
         editViewController.delegate = self;
         
         if ([sender isKindOfClass:[INVProjectTableViewCell class]]) {
             NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
             INVProject *project = [self.dataResultsController objectAtIndexPath:indexPath];
             
             editViewController.currentProject = project;
         } else {
             editViewController.currentProject = nil;
         }
     }
 }

#pragma mark - helper
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

#pragma mark - accessor
-(INVGenericTableViewDataSource*)dataSource {
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController forTableView:self.tableView];
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVProjectTableViewCell *cell,INVProject* project,NSIndexPath* indexPath ){
            cell.delegate = self;
            cell.projectId = project.projectId;
            
            cell.name.text = project.name;
            
            NSArray *files = [self.globalDataManager.invServerClient.projectManager packagesForProjectId:project.projectId];
            NSArray *members = self.globalDataManager.invServerClient.accountManager.accountMembership;
            
            cell.fileCount.text = [NSString stringWithFormat:@"\uf0c5 %i", files.count];
            cell.userCount.text = [NSString stringWithFormat:@"\uf0c0 %i", members.count];
            
            NSString* createdOnStr = NSLocalizedString(@"CREATED_ON", nil);
            NSString* createdOnWithDateStr =[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"CREATED_ON", nil), [self.dateFormatter stringFromDate:project.createdAt]];
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:createdOnWithDateStr];
            [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, createdOnStr.length-1)];
            [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(createdOnStr.length,createdOnWithDateStr.length-createdOnStr.length)];
            
            cell.createdOnLabel.attributedText = attrString;
            
#warning This shoud eventually be provided as a selected by user during project creation and should subsequently be pulled from server. If user does not select one, we randomly pick one
            NSInteger index = arc4random_uniform(5); // We have 5 canned images
            NSString* thumbnail = [NSString stringWithFormat:@"project_thumbnail_%ld",(long)index];
            UIImage* tempImage = [UIImage imageNamed:thumbnail];
            cell.thumbnailImageView.image = [UIImage resizeImage:tempImage toSize:cell.thumbnailImageView.frame.size];
            
        };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectCell" configureBlock:cellConfigurationBlock];
    
    }
    return _dataSource;
}

-(INVProjectManager*) projectManager {
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.projectManager.fetchRequestForProjects managedObjectContext:self.projectManager.managedObjectContext sectionNameKeyPath:@"projectId" cacheName:nil];
        
    }
    return  _dataResultsController;
}

-(NSDateFormatter*)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

-(void) onProjectDeleted:(INVProjectTableViewCell *)sender {
    NSNumber *projectId = sender.projectId;
    
    [[[INVGlobalDataManager sharedInstance] invServerClient] deleteProjectWithId:projectId ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self fetchProjectList];
    }];
}

-(void) onProjectEdited:(INVProjectTableViewCell *)sender {
    [self performSegueWithIdentifier:@"editProject" sender:sender];
}

-(void) onProjectEditSaved:(INVProjectEditViewController *)controller {
    [self fetchProjectList];
}

@end
