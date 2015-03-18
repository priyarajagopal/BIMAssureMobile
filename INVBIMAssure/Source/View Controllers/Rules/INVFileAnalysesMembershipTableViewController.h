//
//  INVFileAnalysesMembershipTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVFileAnalysesMembershipTableViewController : INVCustomTableViewController
@property (nonatomic, assign) BOOL showAnalysesForPkg;
@property (nonatomic, copy) NSNumber *projectId;
@property (nonatomic, copy) NSNumber *fileId;

- (void)resetAnalysesEntries;
@end
