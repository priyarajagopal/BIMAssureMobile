//
//  UIView+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (INVCustomizations)

- (id)findSubviewOfClass:(Class)kls predicate:(NSPredicate *)predicate;

@end
