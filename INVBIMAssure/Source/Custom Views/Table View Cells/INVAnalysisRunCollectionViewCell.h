//
//  INVAnalysisRunCollectionViewCell.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EmpireMobileManager/INVAnalysisRun.h>

@interface INVAnalysisRunCollectionViewCell : UICollectionViewCell

@property (nonatomic) INVAnalysis *analysis;
@property (nonatomic) INVAnalysisRun *run;
@property (nonatomic) INVAnalysisRunResultsArray runResults;

@end
