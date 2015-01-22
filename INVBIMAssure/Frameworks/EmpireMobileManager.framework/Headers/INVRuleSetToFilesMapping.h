//
//  INVRuleSetToFilesMapping.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface INVRuleSetToFilesMapping : NSManagedObject

@property (nonatomic, retain) NSNumber * ruleSetId;
@property (nonatomic, retain) NSArray* files;

@end
