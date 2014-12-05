//
//  INVRuleExecutionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/3/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleExecutionsTableViewController.h"


static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRuleExecutionsTableViewController ()
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,strong)INVFileArray files;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@end

@implementation INVRuleExecutionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"RULE_EXECUTIONS", nil);
    
    UINib* reNib = [UINib nibWithNibName:@"INVRuleExecutionTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:reNib forCellReuseIdentifier:@"RuleExecutionTVC"];

    
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.refreshControl = nil;
    
    [self setupTableViewDataSource];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self fetchFilesFromServer];
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

    self.tableView.dataSource = self.dataSource;
}

#pragma mark - server side
-(void)fetchFilesFromServer {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            self.files = self.projectManager.projectFiles;
        }
        else {
#warning - display error
        }
    }];
}


-(void)fetch

#pragma mark - accessor


@end
