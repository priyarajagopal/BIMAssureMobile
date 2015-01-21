//
//  INVModelViewerContainerViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelViewerContainerViewController.h"
#import "INVModelViewerViewController.h"

@interface INVModelViewerContainerViewController ()

@end

@implementation INVModelViewerContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[INVModelViewerViewController class]]) {
        self.modelViewController = segue.destinationViewController;
    }
}

-(void) setModelViewController:(INVModelViewerViewController *)modelViewController {
    _modelViewController = modelViewController;
    
    _modelViewController.modelId = self.modelId;
    _modelViewController.fileVersionId = self.fileVersionId;
}

-(void) setModelId:(NSNumber *)modelId {
    _modelId = modelId;
    
    _modelViewController.modelId = modelId;
}

-(void) setFileVersionId:(NSNumber *)fileVersionId {
    _fileVersionId = fileVersionId;
    
    _modelViewController.fileVersionId = fileVersionId;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
