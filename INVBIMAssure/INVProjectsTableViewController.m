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

static const NSInteger DEFAULT_CELL_HEIGHT = 300;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;

@interface INVProjectsTableViewController ()
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic,strong)INVProjectDetailsTabViewController* projectDetailsController;
@end

@implementation INVProjectsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title = NSLocalizedString(@"PROJECTS", nil);
    
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
    UINib* nib = [UINib nibWithNibName:@"INVProjectTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ProjectCell"];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self fetchProjectList];
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.dataResultsController.fetchedObjects.count;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return DEFAULT_NUM_ROWS_SECTION;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    INVProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell" forIndexPath:indexPath];
 
     // Configure the cell...
     INVProject* project = [self.dataResultsController objectAtIndexPath:indexPath];
     cell.name.text = project.name;
     NSString* createdOnStr = NSLocalizedString(@"CREATED_ON", nil);
     NSString* createdOnWithDateStr =[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"CREATED_ON", nil), [self.dateFormatter stringFromDate:project.createdAt]];
     NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:createdOnWithDateStr];
     [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, createdOnStr.length-1)];
     [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(createdOnStr.length,createdOnWithDateStr.length-createdOnStr.length)];
                                  
     cell.createdOnLabel.attributedText = attrString;
     
#warning when thumbnail url is available on server use it to load images asynchronously. For now, picking from bundle
     NSUInteger random = self.dataResultsController.fetchedObjects.count;
     NSInteger index = arc4random_uniform(random);
     NSString* thumbnail = [NSString stringWithFormat:@"project_thumbnail_%ld",(long)index];
     cell.thumbnailImageView.image = [UIImage imageNamed:thumbnail];

     return cell;
 }


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ProjectDetailSegue" sender:self];
}


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
         INVProjectDetailsTabViewController* projectDetailsController = (INVProjectDetailsTabViewController*)segue.destinationViewController;
         
         UINavigationController* navController = projectDetailsController.viewControllers[0];;
         INVProjectFilesListViewController* fileListController = (INVProjectFilesListViewController*) navController.topViewController;
         [fileListController.navigationItem setLeftBarButtonItem: [self.splitViewController displayModeButtonItem]];

         fileListController.projectId = project.projectId;

     }
 }


#pragma mark - accessor

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

@end
