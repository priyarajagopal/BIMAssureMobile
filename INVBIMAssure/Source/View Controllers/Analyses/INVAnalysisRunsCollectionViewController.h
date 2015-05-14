//
//  INVAnalysisRunsCollectionViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomCollectionViewController.h"

@interface INVAnalysisRunsCollectionViewController : INVCustomCollectionViewController

@property (copy) NSNumber *projectId;
@property (copy) NSNumber *packageMasterId;
@property (copy) NSNumber *packageVersionId;

@end
