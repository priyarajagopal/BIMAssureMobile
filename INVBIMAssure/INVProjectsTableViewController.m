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
#import "INVRulesListViewController.h"
#import "INVProjectListSplitViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 300;
static const NSInteger TABINDEX_PROJECT_FILES = 0;
static const NSInteger TABINDEX_PROJECT_RULESETS = 1;

@interface INVProjectsTableViewController ()
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
   
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
   
    [self setupTableViewDataSource];
    
#warning move this to within setupTableViewDataSource
    self.tableView.dataSource = self.dataSource;
    UINib* nib = [UINib nibWithNibName:@"INVProjectTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ProjectCell"];
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.dataSource = self.dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self fetchProjectList];
}

-(void)setupTableViewDataSource {
    self.dataSource = [[INVGenericTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVProjectTableViewCell *cell,INVProject* project,NSIndexPath* indexPath ){
        cell.name.text = project.name;
        NSString* createdOnStr = NSLocalizedString(@"CREATED_ON", nil);
        NSString* createdOnWithDateStr =[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"CREATED_ON", nil), [self.dateFormatter stringFromDate:project.createdAt]];
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:createdOnWithDateStr];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, createdOnStr.length-1)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(createdOnStr.length,createdOnWithDateStr.length-createdOnStr.length)];
        
        cell.createdOnLabel.attributedText = attrString;
        
        NSUInteger random = self.dataResultsController.fetchedObjects.count;
        NSInteger index = arc4random_uniform(random);
        NSString* thumbnail = [NSString stringWithFormat:@"project_thumbnail_%ld",(long)index];
        cell.thumbnailImageView.image = [UIImage imageNamed:thumbnail];
        
        
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectCell" configureBlock:cellConfigurationBlock];
}

#pragma mark - server side
-(void)fetchProjectList {
    [self.globalDataManager.invServerClient getAllProjectsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
#pragma note Yes - you could have directly accessed accounts from accountManager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.tableView reloadData];
            }
            else {
#warning - display error
            }
            
        }
        else {
#warning - display error
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
    INVProject* project = [self.dataResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqual:@"ProjectDetailSegue"]) {
         INVProjectListSplitViewController* projectsSplitViewController = (INVProjectListSplitViewController*)self.splitViewController;
         projectsSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
         
         INVProjectDetailsTabViewController* projectDetailsController = (INVProjectDetailsTabViewController*)segue.destinationViewController;

         UINavigationController* navController = projectDetailsController.viewControllers[TABINDEX_PROJECT_FILES];
         INVProjectFilesListViewController* fileListController = (INVProjectFilesListViewController*) navController.topViewController;
         [fileListController.navigationItem setLeftBarButtonItem: [self.splitViewController displayModeButtonItem]];

         fileListController.projectId = project.projectId;
         
         UINavigationController* rsNavController = projectDetailsController.viewControllers[TABINDEX_PROJECT_RULESETS];;
         INVRulesListViewController* ruleSetController = (INVRulesListViewController*) rsNavController.topViewController;
         [ruleSetController.navigationItem setLeftBarButtonItem: [self.splitViewController displayModeButtonItem]];
         
         ruleSetController.projectId = project.projectId;


     }
    
 }


#pragma mark - accessor

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.projectManager.fetchRequestForProjects managedObjectContext:self.projectManager.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil];
        
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

@end
