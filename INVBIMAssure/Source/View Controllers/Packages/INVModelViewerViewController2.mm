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
using namespace std;

@interface INVModelViewerViewController2 () {
    Viewer *_viewer;
    BOOL _touch_moved;
}

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation INVModelViewerViewController2

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *) self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

#if !(TARGET_IPHONE_SIMULATOR)
    view.drawableMultisample = GLKViewDrawableMultisample4X;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupGL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addObservers];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_viewer->set_viewport(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        [self loadModel];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObservers];
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

    NSString *authToken = [INVGlobalDataManager sharedInstance].invServerClient.accountManager.tokenOfSignedInAccount;
    _viewer->set_auth_token([authToken cStringUsingEncoding:NSASCIIStringEncoding]);
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _viewer->set_viewport(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _viewer->set_viewport(0, 0, size.width, size.height);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    _viewer->draw();
}

- (glm::vec2 *)getTouchPoints:(NSSet *)touches
{
    glm::vec2 *pts = 0;
    if (touches.count > 0) {
        pts = new glm::vec2[touches.count];
        for (int i = 0; i < touches.count; i++) {
            CGPoint pt = [[touches allObjects][i] locationInView:self.view];
            pts[i] = glm::vec2(pt.x, pt.y);
        }
    }
    return pts;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touch_moved = NO;
    [super touchesBegan:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    glm::vec2 *pts = [self getTouchPoints:allTouches];
    if (pts) {
        _viewer->on_touch_begin(allTouches.count, pts);
        delete[] pts;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSSet *allTouches = [event allTouches];

    if (allTouches.count == 1) {
        // to prevent rotating and picking at the same time
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        CGPoint oldTouchPoint = [[touches anyObject] previousLocationInView:self.view];
        if (fabs(touchPoint.x - oldTouchPoint.x) > 1.5 || fabs(touchPoint.y - oldTouchPoint.y) > 1.5)
            _touch_moved = YES;
        else
            return;
    }
    glm::vec2 *pts = [self getTouchPoints:allTouches];

    if (pts) {
        _viewer->on_touch_move(allTouches.count, pts);
        delete[] pts;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSSet *allTouches = [event allTouches];
    glm::vec2 *pts = [self getTouchPoints:allTouches];
    if (pts) {
        _viewer->on_touch_end(allTouches.count, pts);
        delete[] pts;
    }

    if (!_touch_moved && allTouches.count == 1) {
        UITouch *touch = [touches anyObject];
        if (touch.tapCount == 1) {
            self->_viewer->deselect_all_elements();
            CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
            ElementId id = self->_viewer->pick_element_on_screen(touchPoint.x, touchPoint.y);
            if (id > 0) {
                NSLog(@"Location in view %@", NSStringFromCGPoint(touchPoint));
                self->_viewer->set_elements_selected({id}, true);
            }
        }
        _touch_moved = NO;
    }
}

- (void)onResume
{
    _viewer->request_render();
}

#pragma mark - public methods

- (void)highlightElement:(NSString *)elementId
{
    int32_t elementNum = [elementId intValue];

    ElementIdList selectedElements = _viewer->get_selected_elements();
    if (std::find(selectedElements.begin(), selectedElements.end(), elementNum) != selectedElements.end()) {
        // already selected. Nothing to do ...
    }
    else {
        _viewer->deselect_all_elements();
        ElementIdList elementToHightlight;
        elementToHightlight.push_back(elementNum);
        _viewer->set_elements_selected(elementToHightlight, true);
    }
}

- (void)highlightAndZoomElement:(NSString *)elementId
{
    int32_t elementNum = [elementId intValue];

    ElementIdList selectedElements = _viewer->get_selected_elements();
    if (std::find(selectedElements.begin(), selectedElements.end(), elementNum) != selectedElements.end()) {
        // already selected. Nothing to do ...
    }
    else {
        _viewer->deselect_all_elements();
        ElementIdList elementToHightlight;
        elementToHightlight.push_back(elementNum);
        _viewer->set_elements_selected(elementToHightlight, true);
        _viewer->fit_camera_to_element(elementToHightlight[0]);
    }
}

#pragma mark - IBActions
- (IBAction)toggleGlass:(id)sender
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
    BOOL selectedElementsHidden = NO;
    ElementIdList selectedElements = _viewer->get_selected_elements();
    for (std::vector<int>::size_type i = 0; i != selectedElements.size(); i++) {
        uint32_t element = selectedElements[i];
        if (_viewer->is_element_visible(element)) {
            selectedElementsHidden = YES;
        }
    }
    if (selectedElementsHidden) {
        _viewer->set_elements_visible(selectedElements, false);
    }
    else {
        _viewer->set_elements_visible(selectedElements, true);
    }
}

- (IBAction)zoomIntoSelectedElement:(id)sender
{
    ElementIdList ids = _viewer->get_selected_elements();
    if (ids.size() > 0)
        _viewer->fit_camera_to_element(ids[0]);
}

#pragma mark - observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onResume)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
@end
