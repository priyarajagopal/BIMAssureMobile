//
//  INVRuleSetFilesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetManageFilesTableViewController.h"
#import "INVGenericTableViewDataSource.h"
#import "INVRuleSetIncludedFilesViewController.h"

@interface INVRuleSetManageFilesTableViewController ()
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic, strong)INVGenericTableViewDataSource* rsFilesDataSource;
@end

#pragma mark - implementation
@implementation INVRuleSetManageFilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"MANAGE_RULESETS", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - accessors


-(INVGenericTableViewDataSource*)rsFilesDataSource {
    if (!_rsFilesDataSource) {
        INVProjectManager* projectManager = self.globalDataManager.invServerClient.projectManager;
        _rsFilesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:projectManager.projectFiles];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVFile* file,NSIndexPath* indexPath ){
            cell.textLabel.text = file.fileName;
            
            NSString* versionStr = NSLocalizedString(@"VERSION", nil);
            NSString* versionAttrStr =[NSString stringWithFormat:@"%@ : %@",versionStr,file.version ];
            cell.detailTextLabel.text = versionAttrStr;
            
        };
        [_rsFilesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _rsFilesDataSource;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IncludedFilesSegue"]) {
        INVRuleSetIncludedFilesViewController* includedFilesTVC = segue.destinationViewController;
        includedFilesTVC.projectId = self.projectId;
        includedFilesTVC.ruleSetId = self.ruleSetId;
        includedFilesTVC.showFilesForRuleSetId = YES;
    }
    else if ([segue.identifier isEqualToString:@"ExcludedFilesSegue"]) {
        INVRuleSetIncludedFilesViewController* includedFilesTVC = segue.destinationViewController;
        includedFilesTVC.projectId = self.projectId;
        includedFilesTVC.ruleSetId = self.ruleSetId;
        includedFilesTVC.showFilesForRuleSetId = NO;
    }
}


@end
