//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceGeneralTypeParamTableViewCell.h"

#import "UIView+INVCustomizations.h"

static NSString *const INVRuleInstanceGeneralTypeParamTableViewCell_TypesExpandedKey = @"typesExpanded";
static NSString *const INVRuleInstanceGeneralTypeParamTableViewCell_DateExpandedKey = @"dateExpanded";
static NSString *const INVRuleInstanceGeneralTypeParamTableViewCell_SelectedTypeKey = @"selectedType";

@interface INVRuleInstanceGeneralTypeParamTableViewCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKeyLabel;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValueTextField;

@property (weak, nonatomic) IBOutlet UIButton *unitsButton;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@property (weak, nonatomic) IBOutlet UIView *unitsButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *typeButtonContainer;

@property (weak, nonatomic) IBOutlet UIView *errorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (weak, nonatomic) IBOutlet UIView *typePickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *typePickerView;

@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;

// Important - this MUST be strong
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *unitsButtonContainerCollapseLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *typeButtonContainerCollapseLayoutConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *errorContainerCollapseLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *typePickerContainerCollapseLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerContainerCollapseLayoutConstraint;

@property (nonatomic, readonly) NSString *valueString;
@property (nonatomic, readwrite) BOOL typesExpanded;
@property (nonatomic, readwrite) BOOL dateExpanded;
@property (nonatomic, readwrite) INVParameterType currentlySelectedType;

@end

@implementation INVRuleInstanceGeneralTypeParamTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (BOOL)becomeFirstResponder
{
    return [self.ruleInstanceValueTextField becomeFirstResponder];
}

#pragma mark - Getters and Setters

- (BOOL)typesExpanded
{
    return [self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_TypesExpandedKey] boolValue];
}

- (void)setTypesExpanded:(BOOL)typesExpanded
{
    self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_TypesExpandedKey] = @(typesExpanded);
}

- (BOOL)dateExpanded
{
    return [self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_DateExpandedKey] boolValue];
}

- (void)setDateExpanded:(BOOL)dateExpanded
{
    self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_DateExpandedKey] = @(dateExpanded);
}

- (INVParameterType)currentlySelectedType
{
    return [self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_SelectedTypeKey] integerValue];
}

- (void)setCurrentlySelectedType:(INVParameterType)currentlySelectedType
{
    self.actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_SelectedTypeKey] = @(currentlySelectedType);
}

- (NSString *)valueString
{
    id value = self.actualParamDictionary[INVActualParamValue];

    if (value == nil || [value isKindOfClass:[NSNull class]])
        return @"";

    if ([value isKindOfClass:[NSString class]])
        return value;

    if ([value isKindOfClass:[NSNumber class]])
        return [value stringValue];

    if ([value isKindOfClass:[NSDate class]]) {
        static NSDateFormatter *dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [NSDateFormatter new];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
        });

        return [dateFormatter stringFromDate:value];
    }

    [NSException raise:NSInvalidArgumentException format:@"Unknown class of value %@", value];

    return value;
}

#pragma mark - Content Management

- (void)reloadCell
{
    [self updateUI];

    UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)updateUI
{
    if ([self tintColor]) {
        self.ruleInstanceKeyLabel.textColor = self.tintColor;
        self.ruleInstanceValueTextField.textColor = self.tintColor;

        self.unitsButton.titleLabel.textColor = self.tintColor;
        self.typeButton.titleLabel.textColor = self.tintColor;
    }

    self.ruleInstanceKeyLabel.text = self.actualParamDictionary[INVActualParamDisplayName];
    self.ruleInstanceValueTextField.text = self.valueString;

    if (self.actualParamDictionary[INVActualParamUnit] && (self.currentlySelectedType == INVParameterTypeNumber)) {
        self.unitsButtonContainer.hidden = NO;
        [self.unitsButtonContainer removeConstraint:self.unitsButtonContainerCollapseLayoutConstraint];

        if ([self.actualParamDictionary[INVActualParamUnit] isKindOfClass:[NSNull class]]) {
            [self.unitsButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
        }
        else {
            [self.unitsButton setTitle:self.actualParamDictionary[INVActualParamUnit] forState:UIControlStateNormal];
        }
    }
    else {
        self.unitsButtonContainer.hidden = YES;
        [self.unitsButtonContainer addConstraint:self.unitsButtonContainerCollapseLayoutConstraint];
    }

    if (self.actualParamDictionary[INVActualParamError]) {
        self.errorContainerView.hidden = NO;
        [self.errorContainerView removeConstraint:self.errorContainerCollapseLayoutConstraint];

        self.errorMessageLabel.text = self.actualParamDictionary[INVActualParamError];
    }
    else {
        self.errorContainerView.hidden = YES;
        [self.errorContainerView addConstraint:self.errorContainerCollapseLayoutConstraint];
    }

    [self.typeButton setTitle:INVParameterTypeToString(self.currentlySelectedType) forState:UIControlStateNormal];

    if ([self.actualParamDictionary[INVActualParamType] count] > 1) {
        self.typeButtonContainer.hidden = NO;
        [self.typeButtonContainer removeConstraint:self.typeButtonContainerCollapseLayoutConstraint];
    }
    else {
        self.typeButtonContainer.hidden = YES;
        [self.typeButtonContainer addConstraint:self.typeButtonContainerCollapseLayoutConstraint];
    }

    if (self.typesExpanded) {
        self.typePickerContainerView.hidden = NO;
        [self.typePickerContainerView removeConstraint:self.typePickerContainerCollapseLayoutConstraint];
    }
    else {
        self.typePickerContainerView.hidden = YES;
        [self.typePickerContainerView addConstraint:self.typePickerContainerCollapseLayoutConstraint];
    }

    if (self.dateExpanded) {
        self.datePickerContainerView.hidden = NO;
        [self.datePickerContainerView removeConstraint:self.datePickerContainerCollapseLayoutConstraint];
    }
    else {
        self.datePickerContainerView.hidden = YES;
        [self.datePickerContainerView addConstraint:self.datePickerContainerCollapseLayoutConstraint];
    }

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

- (void)setActualParamDictionary:(INVActualParamKeyValuePair)actualParamDictionary
{
    _actualParamDictionary = actualParamDictionary;

    if (_actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_SelectedTypeKey] == nil) {
        _actualParamDictionary[INVRuleInstanceGeneralTypeParamTableViewCell_SelectedTypeKey] =
            [_actualParamDictionary[INVActualParamType] firstObject];
    }

    [self updateUI];
}

#pragma mark - IBActions

- (IBAction)ruleInstanceValueTextChanged:(id)sender
{
    NSError *error = [[INVRuleParameterParser instance] isValueValid:self.ruleInstanceValueTextField.text
                                                    forParameterType:self.currentlySelectedType
                                                     withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]];
    if (error) {
        self.actualParamDictionary[INVActualParamError] = error.localizedDescription;
    }
    else {
        id newValue = nil;

        switch (self.currentlySelectedType) {
            case INVParameterTypeString:
                newValue = self.ruleInstanceValueTextField.text;
                break;

            case INVParameterTypeNumber: {
                NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                newValue = [numberFormatter numberFromString:self.ruleInstanceValueTextField.text];
                break;
            }

            default:
                [NSException raise:NSInvalidArgumentException format:@"Uknown parameter type %i", self.currentlySelectedType];
                break;
        }

        self.actualParamDictionary[INVActualParamValue] = newValue ?: [NSNull null];
        [self.actualParamDictionary removeObjectForKey:INVActualParamError];
    }

    [self reloadCell];
}

- (IBAction)toggleTypesPicker:(id)sender
{
    [self.ruleInstanceValueTextField resignFirstResponder];

    self.dateExpanded = NO;
    self.typesExpanded = !self.typesExpanded;

    [self reloadCell];
}

- (IBAction)datePickerValueChanged:(id)sender
{
    NSError *error = [[INVRuleParameterParser instance] isValueValid:self.datePickerView.date
                                                    forParameterType:self.currentlySelectedType
                                                     withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]];

    if (error) {
        self.actualParamDictionary[INVActualParamError] = error.localizedDescription;
    }
    else {
        self.actualParamDictionary[INVActualParamValue] = self.datePickerView.date;
        [self.actualParamDictionary removeObjectForKey:INVActualParamError];
    }

    [self reloadCell];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Hide the types picker if it's visible
    if (self.typesExpanded) {
        [self toggleTypesPicker:nil];
    }

    if (self.currentlySelectedType == INVParameterTypeDate) {
        if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]]) {
            self.actualParamDictionary[INVActualParamValue] = [NSDate date];
        }

        self.datePickerView.date = self.actualParamDictionary[INVActualParamValue];
        self.dateExpanded = !self.dateExpanded;

        [self reloadCell];

        return NO;
    }

    return YES;
}

#pragma mark - UIPickerViewDatasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.actualParamDictionary[INVActualParamType] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return INVParameterTypeToString([self.actualParamDictionary[INVActualParamType][row] integerValue]);
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    INVParameterType type = [self.actualParamDictionary[INVActualParamType][row] integerValue];
    if (type == self.currentlySelectedType)
        return;

    self.actualParamDictionary[INVActualParamValue] = [NSNull null];
    if (self.actualParamDictionary[INVActualParamUnit]) {
        self.actualParamDictionary[INVActualParamUnit] = [NSNull null];
    }

    self.currentlySelectedType = type;

    [self reloadCell];
}

@end
