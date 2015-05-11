//
//  INVModelViewerViewController2.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/10/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelViewerViewController2.h"
#import <OpenGLES/ES2/glext.h>
#include "viewer.h"
using namespace renderlib;

@interface INVModelViewerViewController2 () {
    Viewer* _viewer;
}


@property (strong, nonatomic) EAGLContext *context;

@end

@implementation INVModelViewerViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
#if !(TARGET_IPHONE_SIMULATOR)
  //  view.drawableMultisample = GLKViewDrawableMultisample4X;
#endif
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupGL];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewer->set_viewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self loadModel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    _viewer = new Viewer();
    _viewer->init();
    
}

- (void)loadModel
{
    
    NSURLRequest *request =
    [[INVGlobalDataManager sharedInstance].invServerClient requestToFetchGeomInfoForPkgVersion:self.fileVersionId];
   
    /*
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *parsedResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                               
                               NSLog(@"loadModel:%@",parsedResults);
                               for (NSString *geomPath in parsedResults[@"outputFiles"]) {
                                   NSLog(@"geomPath:%@",[[NSURL URLWithString:geomPath ]lastPathComponent]);
                                   NSURLRequest *geomRequest = [[INVGlobalDataManager sharedInstance].invServerClient
                                                                requestToFetchModelViewForPkgVersion:self.fileVersionId
                                                                forFile:[[NSURL URLWithString:geomPath ]lastPathComponent]];
                                   
                                   [self->_ctmParser process:geomRequest];
                               }
                           }];

     */
    NSString* authToken = [INVGlobalDataManager sharedInstance].invServerClient.accountManager.tokenOfSignedInAccount;
    _viewer->set_auth_token([authToken cStringUsingEncoding:NSASCIIStringEncoding] );
    _viewer->load_model([[request.URL absoluteString] cStringUsingEncoding:NSASCIIStringEncoding]);
    
}


- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    delete _viewer;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    //_viewer->set_viewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

/*
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
 [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
 _viewer->set_viewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
 }
 
 - (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
 {
 [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
 _viewer->set_viewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
 }
 */

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    _viewer->draw();
}

- (glm::vec2*)getTouchPoints:(NSSet *)touches
{
    glm::vec2* pts = 0;
    if (touches.count > 0)
    {
        pts = new glm::vec2[touches.count];
        for (int i=0; i < touches.count; i++)
        {
            CGPoint pt = [[touches allObjects][i] locationInView:self.view];
            pts[i] = glm::vec2(pt.x, pt.y);
        }
    }
    return pts;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSSet* allTouches = [event allTouches];
    glm::vec2* pts = [self getTouchPoints:allTouches];
    if (pts)
    {
        _viewer->on_touch_begin(allTouches.count, pts);
        delete [] pts;
    }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSSet* allTouches = [event allTouches];
    glm::vec2* pts = [self getTouchPoints:allTouches];
    if (pts)
    {
        _viewer->on_touch_move(allTouches.count, pts);
        delete [] pts;
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSSet* allTouches = [event allTouches];
    glm::vec2* pts = [self getTouchPoints:allTouches];
    if (pts)
    {
        _viewer->on_touch_end(allTouches.count, pts);
        delete [] pts;
    }
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2)
    {
        _viewer->deselect_all_elements();
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        ElementId id = _viewer->pick_element_on_screen(touchPoint.x, touchPoint.y);
        if (id > 0)
            _viewer->set_elements_selected({id}, true);
    }
}

-(IBAction)toggleGlass:(id)sender
{
    bool glass_mode = _viewer->is_glass_mode();
    _viewer->set_glass_mode(!glass_mode);
}



- (IBAction)goHome:(id)sender
{
    _viewer->reset_camera();
}

- (IBAction)toggleShadow:(id)sender
{
}


- (IBAction)toggleVisible:(id)sender
{
}

- (IBAction)highlightElement:(NSString *)elementId
{
}
@end
