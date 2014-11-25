//
//  INVSearchView.m
//  INVSearchField
//
//  Created by Richard Ross on 11/25/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "INVSearchView.h"
#import <VENTokenField/VENTokenField.h>

@interface INVSearchView()<UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, VENTokenFieldDataSource, VENTokenFieldDelegate>

@property IBOutlet VENTokenField *inputField;
@property IBOutlet UIButton *tagsButton;

-(IBAction) _showTagsDropdown:(id) sender;

-(void) _onTagToggled:(NSString *) tag;
-(void) _onTagAdded:(NSString *) tag;
-(void) _onTagRemoved:(NSString *) tag;

@end

@implementation INVSearchView {
    NSMutableOrderedSet *_selectedTags;
    
    UITableViewController *_tagsController;
    UIPopoverController *_popoverController;
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
    } else {
        _tagsButton.enabled = NO;
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
    [self reloadData];
    
    // Change this on the next run-loop tick, as if we don't,
    // -[VENTokenField awakeFromNib] will set the to label text back.
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_inputField.toLabelText = nil;
        self->_inputField.placeholderText = NSLocalizedString(@"SEARCH", nil);
    });
}

#pragma mark - UIPopoverControllerDelegate methods

-(void) popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    if (*view == self) {
        *rect = _tagsButton.frame;
    }
}

#pragma mark - UITableViewDataSource methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(numberOfTagsInSearchView:)]) {
        return [_dataSource numberOfTagsInSearchView:self];
    }
    
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basicCell"];
    }
    
    if ([_dataSource respondsToSelector:@selector(searchView:tagAtIndex:)]) {
        cell.textLabel.text = [_dataSource searchView:self tagAtIndex:indexPath.row];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([_dataSource respondsToSelector:@selector(searchView:isTagSelected:)]) {
        if ([_dataSource searchView:self isTagSelected:cell.textLabel.text]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self _onTagToggled:cell.textLabel.text];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - VENTokenFieldDataSource methods

-(NSUInteger) numberOfTokensInTokenField:(VENTokenField *)tokenField {
    return _selectedTags.count;
}

-(NSString *) tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    return _selectedTags[index];
}

#pragma mark - VENTokenFieldDelegate methods

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
    if (_tagsController == nil) {
        _tagsController = [UITableViewController new];
        _tagsController.tableView.dataSource = self;
        _tagsController.tableView.delegate = self;
    }
    
    if (_popoverController == nil) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:_tagsController];
        _popoverController.delegate = self;
        _popoverController.popoverContentSize = CGSizeMake(240, 240);
    }
    
    [_popoverController presentPopoverFromRect:[sender frame]
                                        inView:self
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
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