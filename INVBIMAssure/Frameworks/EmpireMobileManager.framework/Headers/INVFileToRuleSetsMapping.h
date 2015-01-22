//
//  INVFileToRuleSetsMapping.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface INVFileToRuleSetsMapping : NSManagedObject

@property (nonatomic, retain) NSNumber * packageId;
@property (nonatomic, retain) id ruleSets;

@end
