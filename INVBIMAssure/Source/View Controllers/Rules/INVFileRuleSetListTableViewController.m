//
//  INVFileRuleSetListTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVFileRuleSetListTableViewController.h"
#import "INVGeneralAddRemoveTableViewCell.h"

static const NSInteger SECTION_RULESETLIST = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVFileRuleSetListTableViewController () <INVGeneralAddRemoveTableViewCellAcionDelegate>
@property (nonatomic,strong)INVGenericTableViewDataSource* ruleSetsDataSource;
@property (nonatomic, strong) INVProjectManager* projectManager;
@property (nonatomic, strong) INVRulesManager* rulesManager;
@property (nonatomic, strong) INVRuleSetMutableArray  ruleSets;
@property (nonatomic, assign) BOOL observersAdded;
@end

@implementation INVFileRuleSetListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UINib* projectCellNib = [UINib nibWithNibName:@"INVGeneralAddRemoveTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:projectCellNib forCellReuseIdentifier:@"ProjectFileCell"];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
     if (self.showRuleSetsForFileId) {
         [self setHeaderViewWithHeading:NSLocalizedString(@"RULESETS_INCLUDED_IN_FILE", nil)];
    }
    else {
         [self setHeaderViewWithHeading:NSLocalizedString(@"RULESETS_NOT_INCLUDED_IN_FILE", nil)];
    }
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.dataSource = self.ruleSetsDataSource;
    
    [self addObserversForFileMoveNotification];
    [self fetchListOfProjectRuleSets];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.showRuleSetsForFileId) {
        [self pushAddedRuleSetsForPkgMasterToServer];
        [self pushRemovedRuleSetsForPkgMasterToServer];
    }
    self.tableView.dataSource = nil;
    self.ruleSetsDataSource = nil;
    self.rulesManager = nil;
    self.projectManager = nil;
    self.ruleSets = nil;
    [self removeObserversForFileMoveNotification];
}

#pragma mark - public
-(void)resetRuleSetEntries {
    [self updateRuleSetsFromServer ];
    [self.ruleSetsDataSource updateWithDataArray:self.ruleSets forSection:SECTION_RULESETLIST];
    [self.tableView reloadData];
}

#pragma mark - server side
-(void)fetchListOfProjectRuleSets {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllRuleSetsForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
            [self fetchRuleSetIdsForFile];
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_RULESET_MEMBERSHIP_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];
        }
    }];
}

-(void)fetchRuleSetIdsForFile {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient  getAllRuleSetMembersForPkgMaster:self.fileId WithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
            [self updateRuleSetsFromServer ];
            [self.ruleSetsDataSource updateWithDataArray:self.ruleSets forSection:SECTION_RULESETLIST];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_RULESET_MEMBERSHIP_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];
        }
    }];
}


-(void)pushAddedRuleSetsForPkgMasterToServer {
    NSSet* currentRuleSetsForPkgMaster = [self.globalDataManager.invServerClient.rulesManager ruleSetIdsForPkgMaster:self.fileId];
    NSMutableSet* updatedRuleSetIds = [[NSMutableSet alloc]initWithCapacity:0];
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet* ruleSet = obj;
        [updatedRuleSetIds addObject:ruleSet.ruleSetId];
    }];
    
    [updatedRuleSetIds minusSet:currentRuleSetsForPkgMaster];
    
    [self.globalDataManager.invServerClient addToPkgMaster:self.fileId ruleSets:[updatedRuleSetIds allObjects] withCompletionBlock:^(INVEmpireMobileError *error) {
        if (error ) {
            NSLog(@"Failed to add rule set %@ for pkg master %@ with error %@",updatedRuleSetIds,self.fileId,error);
        }
        else {
            NSLog(@"Succesfully added rule set %@ for pkg master %@ ",updatedRuleSetIds,self.fileId);
        }
    }];

}

-(void)pushRemovedRuleSetsForPkgMasterToServer {
    NSMutableSet* currentRuleSetsForPkgMaster = [[self.globalDataManager.invServerClient.rulesManager ruleSetIdsForPkgMaster:self.fileId]mutableCopy];
    NSMutableSet* updatedRuleSetIds = [[NSMutableSet alloc]initWithCapacity:0];
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet* ruleSet = obj;
        [updatedRuleSetIds addObject:ruleSet.ruleSetId];
    }];
    
    [currentRuleSetsForPkgMaster minusSet:updatedRuleSetIds];
    
    [currentRuleSetsForPkgMaster enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSNumber* idToRemove = obj;
        NSLog(@"Will remove rule set Id %@",idToRemove);
        [self.globalDataManager.invServerClient removeFromPkgMaster:self.fileId ruleSet:idToRemove withCompletionBlock:^(INVEmpireMobileError *error) {
            if (error ) {
                NSLog(@"Failed to remove rule set %@ for pkg master %@ with error %@",idToRemove,self.fileId,error);
            }
            else {
                NSLog(@"Succesfully removed rule set %@ for pkg master %@ ",idToRemove,self.fileId);
            }
        }];
    }];
    
}

#pragma mark - UITableView
-(void)setHeaderViewWithHeading:(NSString*)heading {
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.tableView.frame), DEFAULT_HEADER_HEIGHT)];
    UIColor * medGreyColor = [UIColor colorWithRed:225.0/255 green:225.0/255 blue:225.0/255 alpha:1.0];
    [headerView setBackgroundColor:medGreyColor];
    
    UILabel* headingLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,10, CGRectGetWidth(headerView.frame)-20, DEFAULT_HEADER_HEIGHT )];
    headingLabel.text  = heading;
    headingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [headerView addSubview:headingLabel];
    
    [self.tableView setTableHeaderView:headerView];
}


#pragma mark - INVGeneralAddRemoveTableViewCellAcionDelegate
-(void)addRemoveFileTapped:(INVGeneralAddRemoveTableViewCell*)sender {
    if (sender.isAdded) {
        
    }
}


#pragma mark - accessors
-(INVProjectManager*)projectManager {
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

-(INVRulesManager*)rulesManager {
    if (!_rulesManager) {
        _rulesManager = self.globalDataManager.invServerClient.rulesManager;
    }
    return _rulesManager;
}

-(INVRuleSetMutableArray)ruleSets {
    if (!_ruleSets) {
        _ruleSets = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _ruleSets;
}

-(INVGenericTableViewDataSource*)ruleSetsDataSource {
    if (!_ruleSetsDataSource) {
        
        _ruleSetsDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.ruleSets forSection:SECTION_RULESETLIST forTableView:self.tableView];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVGeneralAddRemoveTableViewCell *cell,INVRuleSet* ruleSet,NSIndexPath* indexPath ){
            cell.name.text = ruleSet.name;
            cell.isAdded = self.showRuleSetsForFileId;
            cell.contentId = ruleSet.ruleSetId;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        };
        [_ruleSetsDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _ruleSetsDataSource;
}

#pragma mark - helpers
-(void)updateRuleSetsFromServer {
    self.ruleSets = [[self.rulesManager ruleSetsForProject:self.projectId]mutableCopy];
    NSSet* rulesetIdsInFile = [self.rulesManager ruleSetIdsForPkgMaster:self.fileId];
    INVRuleSetMutableArray ruleSetsAssociatedWithFile = [[self.rulesManager ruleSetsForIds:[rulesetIdsInFile  allObjects]]mutableCopy];
    if (self.showRuleSetsForFileId) {
        self.ruleSets = ruleSetsAssociatedWithFile;
    }
    else {
        if (ruleSetsAssociatedWithFile && ruleSetsAssociatedWithFile.count) {
            [self.ruleSets removeObjectsInArray:ruleSetsAssociatedWithFile];
        }
    }
}

-(void)removeFromLocalRuleSetList:(NSNumber*)ruleSetId {
    @synchronized (self) {
        __block INVRuleSet* ruleSet;
        [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVRuleSet* temp = obj;
            if ([temp.ruleSetId isEqualToNumber:ruleSetId]) {
                ruleSet = obj;
                *stop = YES;
            }
        }];
        if (ruleSet) {
            [self.ruleSets removeObject:ruleSet];
        }
    }
}

-(void)addToLocalRuleSetList:(NSNumber*)ruleSetId {
    @synchronized (self) {
        __block INVRuleSet* ruleSet;
        INVRuleSetArray ruleSetsInProject = [self.rulesManager ruleSetsForProject:self.projectId];
        [ruleSetsInProject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVRuleSet* temp = obj;
            if ([temp.ruleSetId isEqualToNumber:ruleSetId]) {
                ruleSet = obj;
                *stop = YES;
            }
        }];
        if (ruleSet) {
            [self.ruleSets addObject:ruleSet];
        }
    }
}

#pragma mark - Observer Handling
-(void)addObserversForFileMoveNotification {
    if (self.observersAdded) {
        return;
    }
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserverForName:INV_NotificationAddRemoveCell object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary* userInfo = note.userInfo;
        INVGeneralAddRemoveTableViewCell* tableViewCell = userInfo[@"AddRemoveCell"];
        
        if (self.showRuleSetsForFileId) {
            if (tableViewCell.isAdded) {
                [self removeFromLocalRuleSetList:tableViewCell.contentId];
            }
            else {
                [self addToLocalRuleSetList:tableViewCell.contentId];
            }
        }
        else {
            if (tableViewCell.isAdded) {
                [self addToLocalRuleSetList:tableViewCell.contentId];
            }
            else {
                [self removeFromLocalRuleSetList:tableViewCell.contentId];
            }
        }
        [self.ruleSetsDataSource updateWithDataArray:self.ruleSets forSection:SECTION_RULESETLIST];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
         
    }];
    self.observersAdded = YES;
}

-(void)removeObserversForFileMoveNotification {
    if (!self.observersAdded) {
        return;
    }
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:INV_NotificationAddRemoveCell object:nil];
    self.observersAdded = NO;
}



#pragma mark - Helpers
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];

}

@end
