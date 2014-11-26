//
//  INVSearchView.m
//  INVSearchField
//
//  Created by Richard Ross on 11/25/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//
#import "INVSearchView.h"

#import <VENTokenField/VENTokenField.h>

@interface INVSearchViewTagsDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

-(id) initWithSearchView:(INVSearchView *) searchView;

@property INVSearchView *searchView;

@end

@interface INVSearchViewQuickSearchDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

-(id) initWithSearchView:(INVSearchView *) searchView;

@property INVSearchView *searchView;

@end

@interface INVSearchView()<
    UIPopoverControllerDelegate, UIAlertViewDelegate,
    VENTokenFieldDataSource, VENTokenFieldDelegate
>

@property IBOutlet VENTokenField *inputField;
@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIView *inputFieldContainer;
@property IBOutlet UIButton *tagsButton;
@property IBOutlet UIButton *saveButton;

-(IBAction) _showTagsDropdown:(id) sender;
-(IBAction) _showQuickSearchDropdown:(id) sender;
-(IBAction) _showSaveDialog:(id)sender;

-(void) _onTagToggled:(NSString *) tag;
-(void) _onTagAdded:(NSString *) tag;
-(void) _onTagRemoved:(NSString *) tag;

@end

@implementation INVSearchView {
    NSMutableOrderedSet *_selectedTags;
    
    UIAlertView *_saveDialog;
    
    INVSearchViewTagsDataSource *_tagsDataSource;
    UITableViewController *_tagsController;
    UIPopoverController *_tagsPopoverController;
    
    INVSearchViewQuickSearchDataSource *_quickSearchDataSource;
    UITableViewController *_quickSearchController;
    UIPopoverController *_quickSearchPopoverController;
    
    UIColor *_oldTintColor;
}

#pragma mark - Property accessors

-(void) setDataSource:(id<INVSearchViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self reloadData];
}

-(void) setDelegate:(id<INVSearchViewDelegate>)delegate {
    _delegate = delegate;
    
    [self reloadData];
}

#pragma mark - Public methods

-(NSOrderedSet *) selectedTags {
    return [_selectedTags copy];
}

-(NSString *) searchText {
    return [_inputField inputText];
}

-(void) reloadData {
    _selectedTags = [NSMutableOrderedSet new];
    
    [_tagsController.tableView reloadData];
    
    if ([_dataSource respondsToSelector:@selector(numberOfTagsInSearchView:)]) {
        NSUInteger count = [_dataSource numberOfTagsInSearchView:self];
        _tagsButton.enabled = (count > 0);
        
        for (NSUInteger index = 0; index < count; index++) {
            NSString *tag = nil;
            BOOL selected = NO;
            
            if ([_dataSource respondsToSelector:@selector(searchView:tagAtIndex:)]) {
                tag = [_dataSource searchView:self tagAtIndex:index];
            }
            
            if ([_dataSource respondsToSelector:@selector(searchView:isTagSelected:)]) {
                selected = [_dataSource searchView:self isTagSelected:tag];
            }
            
            if (selected && tag) {
                [_selectedTags addObject:tag];
            }
        }
        
        _saveButton.enabled = (_selectedTags.count > 0);
    } else {
        _tagsButton.enabled = NO;
        _saveButton.enabled = NO;
    }
    
    [_inputField reloadData];
}

-(void) selectTag:(NSString *)tag {
    [self _onTagAdded:tag];
}

-(void) removeTag:(NSString *)tag {
    [self _onTagRemoved:tag];
}

#pragma mark - View Lifecycle

-(void) awakeFromNib {
    [super awakeFromNib];
    
    _tagsDataSource = [[INVSearchViewTagsDataSource alloc] initWithSearchView:self];
    
    _tagsController = [UITableViewController new];
    _tagsController.tableView.dataSource = _tagsDataSource;
    _tagsController.tableView.delegate = _tagsDataSource;
    
    _tagsPopoverController = [[UIPopoverController alloc] initWithContentViewController:_tagsController];
    _tagsPopoverController.delegate = self;
    _tagsPopoverController.popoverContentSize = CGSizeMake(240, 240);
    
    _quickSearchDataSource = [[INVSearchViewQuickSearchDataSource alloc] initWithSearchView:self];
    
    _quickSearchController = [UITableViewController new];
    _quickSearchController.tableView.dataSource = _quickSearchDataSource;
    _quickSearchController.tableView.delegate = _quickSearchDataSource;
    
    _quickSearchPopoverController = [[UIPopoverController alloc] initWithContentViewController:_quickSearchController];
    _quickSearchPopoverController.passthroughViews = @[ self ];
    _quickSearchPopoverController.delegate = self;
    
    // Change this on the next run-loop tick, as if we don't,
    // -[VENTokenField awakeFromNib] will set the to label text back.
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_inputFieldContainer.layer.borderWidth = 1;
        self->_inputFieldContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        self->_inputField.toLabelText = nil;
        self->_inputField.placeholderText = NSLocalizedString(@"SEARCH", nil);
        [self->_inputField setColorScheme:[UIColor darkGrayColor]];
        
        [self reloadData];
    });
}

#pragma mark - UIPopoverControllerDelegate methods

-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == _tagsPopoverController) {
        [[UIView appearance] setTintColor:_oldTintColor];
    }
}

-(void) popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    if (popoverController == _tagsPopoverController) {
        *rect = _tagsButton.frame;
    }
}

#pragma mark - UIAlertViewDelegate methods

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    NSString *groupName = [alertView textFieldAtIndex:0].text;
    if ([_delegate respondsToSelector:@selector(searchView:onTagsSaved:withName:)]) {
        [_delegate searchView:self onTagsSaved:[self selectedTags] withName:groupName];
        [self reloadData];
    }
}

#pragma mark - VENTokenFieldDataSource methods

-(NSUInteger) numberOfTokensInTokenField:(VENTokenField *)tokenField {
    return _selectedTags.count;
}

-(NSString *) tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    return _selectedTags[index];
}

#pragma mark - VENTokenFieldDelegate methods

-(void) tokenFieldDidBeginEditing:(VENTokenField *)tokenField {
    [self _showQuickSearchDropdown:self.inputFieldContainer];
}

-(void) tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index {
    [self _onTagRemoved:_selectedTags[index]];
}

-(void) tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text {
    if ([_delegate respondsToSelector:@selector(searchView:onSearchTextChanged:)]) {
        [_delegate searchView:self onSearchTextChanged:text];
    }
}

-(void) tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    if ([_delegate respondsToSelector:@selector(searchView:onSearchPerformed:)]) {
        [_delegate searchView:self onSearchPerformed:text];
    }
}

#pragma mark - Private methods

-(void) _showTagsDropdown:(id) sender {
    // NOTE: This is a hack to override the tint color. Apparently you can't set a custom tint color while the appearance has its own tint color as well.
    _oldTintColor = UIView.appearance.tintColor;
    UIView.appearance.tintColor = nil;
    
    [_tagsPopoverController presentPopoverFromRect:[sender frame]
                                            inView:self
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
}

-(void) _showQuickSearchDropdown:(id) sender {
    // TODO: Configure popover size.
    [_quickSearchPopoverController presentPopoverFromRect:[sender frame]
                                         inView:self
                       permittedArrowDirections:0
                                       animated:YES];
}

-(void) _showSaveDialog:(id)sender {
    if (_saveDialog == nil) {
        _saveDialog = [[UIAlertView alloc] initWithTitle:@"Save As"
                                                 message:@"Choose a name for this tag set:"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Ok", nil];
        
        _saveDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    
    [_saveDialog show];
}

-(void) _onTagToggled:(NSString *) tag {
    if ([_selectedTags containsObject:tag]) {
        [self _onTagRemoved:tag];
    } else {
        [self _onTagAdded:tag];
    }
}

-(void) _onTagAdded:(NSString *)tag {
    if ([_selectedTags containsObject:tag]) return;
    
    if ([self.delegate respondsToSelector:@selector(searchView:onTagAdded:)]) {
        [self.delegate searchView:self onTagAdded:tag];
        [self reloadData];
    }
}

-(void) _onTagRemoved:(NSString *)tag {
    if (![_selectedTags containsObject:tag]) return;
    
    if ([self.delegate respondsToSelector:@selector(searchView:onTagDeleted:)]) {
        [self.delegate searchView:self onTagDeleted:tag];
        [self reloadData];
    }
}

@end

/** INVSearchViewTagsDataSource */
@implementation INVSearchViewTagsDataSource

-(id) initWithSearchView:(INVSearchView *)searchView {
    if (self = [super init]) {
        self.searchView = searchView;
    }
    
    return self;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchView.dataSource respondsToSelector:@selector(numberOfTagsInSearchView:)]) {
        return [self.searchView.dataSource numberOfTagsInSearchView:self.searchView];
    }
    
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basicCell"];
    }
    
    if ([self.searchView.dataSource respondsToSelector:@selector(searchView:tagAtIndex:)]) {
        cell.textLabel.text = [self.searchView.dataSource searchView:self.searchView tagAtIndex:indexPath.row];
    }
    
    cell.tintColor = [UIColor blueColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([self.searchView.dataSource respondsToSelector:@selector(searchView:isTagSelected:)]) {
        if ([self.searchView.dataSource searchView:self.searchView isTagSelected:cell.textLabel.text]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.searchView _onTagToggled:cell.textLabel.text];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end

@implementation INVSearchViewQuickSearchDataSource

-(id) initWithSearchView:(INVSearchView *)searchView {
    if (self = [super init]) {
        self.searchView = searchView;
    }
    
    return self;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSString *titles[] = {
        @"Tags",
        @"Search History"
    };
    
    return titles[section];
}

@end