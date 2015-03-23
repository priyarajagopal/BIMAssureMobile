//
//  INVAnalysisFilesListTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVAnalysisFilesListTableViewController : INVCustomTableViewController
@property (nonatomic, assign) BOOL showFilesForAnalysisId;
@property (nonatomic, copy) NSNumber *projectId;
@property (nonatomic, copy) NSNumber *analysisId;

- (void)resetFileEntries;
@end
