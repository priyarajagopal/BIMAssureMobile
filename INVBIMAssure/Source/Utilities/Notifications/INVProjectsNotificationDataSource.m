//
//  INVProjectsNotificationDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/23/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVProjectsNotificationDataSource.h"

@interface INVProjectsNotificationDataSource()

@property NSArray *previousProjects;

@end

@implementation INVProjectsNotificationDataSource

-(void) checkForNewData:(void (^)(NSArray *))callback {
    if (INVGlobalDataManager.sharedInstance.loggedInUser == nil) return;
    
    [[INVGlobalDataManager sharedInstance].invServerClient getAllProjectsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        if (error) {
            NSLog(@"%@: Error while getting pending invitations: %@", [self class], error);
            return;
        }
        
        NSMutableArray *notifications = [NSMutableArray new];
        
        INVProjectManager *projectManager = [INVGlobalDataManager sharedInstance].invServerClient.projectManager;
        NSManagedObjectContext *context = projectManager.managedObjectContext;
        NSFetchRequest *fetchRequest = projectManager.fetchRequestForProjects;
        
        NSArray *projects = [context executeFetchRequest:fetchRequest error:nil];
        
        if (self.previousProjects) {
            NSMutableArray *newProjects = [projects mutableCopy];
            NSMutableArray *goneProjects = [self.previousProjects mutableCopy];
            
            [newProjects removeObjectsInArray:self.previousProjects];
            [goneProjects removeObjectsInArray:projects];
            
            
            for (INVProject *project in newProjects) {
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"PROJECT_ADDED_NOTIFICATION_RECIEVED_TITLE", nil), [project name]];
                
                [notifications addObject:[INVNotification notificationWithTitle:title type:INVNotificationTypeProject andData:project]];
            }
            
            for (INVProject *project in goneProjects) {
                NSString *title = [NSString stringWithFormat:NSLocalizedString(@"PROJECT_REMOVED_NOTIFICATION_ACCEPTED_TITLE", nil), [project name]];
                
                [notifications addObject:[INVNotification notificationWithTitle:title type:INVNotificationTypeProject andData:nil]];
            }
        }
        
        self.previousProjects = projects;
        
        callback(notifications);
    }];
}

@end