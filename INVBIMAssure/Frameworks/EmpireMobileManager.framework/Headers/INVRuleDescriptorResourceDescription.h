//
//  INVRuleDescriptorResourceDescription.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 4/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

//@import UIKit;
#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface INVRuleDescriptorResourceDescription : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic) NSString *longDescription;
@property (copy, nonatomic ) NSString *name;
@property (copy, nonatomic ) NSArray *issues;
@property (copy, nonatomic ) NSString *shortDescription;
@end
