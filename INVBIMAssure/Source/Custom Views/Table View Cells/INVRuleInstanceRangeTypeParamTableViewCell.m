//
//  INVRuleInstanceRangeTypeParamTableViewCell.xib
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceRangeTypeParamTableViewCell.h"
#import "UIView+INVCustomizations.h"

static NSString *const INVRuleInstanceRangeTypeParamTableViewCell_IsEditingFromKey = @"isEditingFrom";
static NSString *const INVRuleInstanceRangeTypeParamTableViewCell_TypesExpandedKey = @"typesExpanded";
static NSString *const INVRuleInstanceRangeTypeParamTableViewCell_DateExpandedKey = @"dateExpanded";

static NSString *const INVRuleInstanceRangeTypeParamTableViewCell_FromSelectedTypeKey = @"fromSelectedType";
static NSString *const INVRuleInstanceRangeTypeParamTableViewCell_ToSelectedTypeKey = @"toSelectedType";

@interface INVRuleInstanceRangeTypeParamTableViewCell () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *parameterNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIButton *fromUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *toUnitButton;

@property (weak, nonatomic) IBOutlet UIView *fromUnitContainerView;
@property (weak, nonatomic) IBOutlet UIView *toUnitContainerView;

@property (weak, nonatomic) IBOutlet UIButton *fromTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *toTypeButton;

@property (weak, nonatomic) IBOutlet UIView *fromTypeContainerView;
@property (weak, nonatomic) IBOutlet UIView *toTypeContainerView;

@property (weak, nonatomic) IBOutlet UITextField *fromValueField;
@property (weak, nonatomic) IBOutlet UITextField *toValueField;

@property (weak, nonatomic) IBOutlet UIView *errorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@property (weak, nonatomic) IBOutlet UIView *typePickerContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *typePickerView;

@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;

// NOTE: must be strong
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fromUnitCollapseConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toUnitCollapseConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fromTypeCollapseConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toTypeCollapseConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *errorContainerCollapseLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *typePickerContainerCollapseLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerContainerCollapseLayoutConstraint;

@property (nonatomic, readwrite) BOOL isEditingFrom;
@property (nonatomic, readwrite) BOOL typesExpanded;
@property (nonatomic, readwrite) BOOL dateExpanded;
@property (nonatomic, readwrite) INVParameterType fromSelectedType;
@property (nonatomic, readwrite) INVParameterType toSelectedType;

@property (nonatomic, readonly) NSString *fromValueString;
@property (nonatomic, readonly) NSString *toValueString;

@property (readonly) NSArray *fromTypes;
@property (readonly) NSArray *toTypes;

@property (readonly) NSDictionary *fromTypeConstraints;
@property (readonly) NSDictionary *toTypeConstraints;

- (IBAction)fromValueTextChanged:(id)sender;
- (IBAction)toValueTextChanged:(id)sender;

@end

@implementation INVRuleInstanceRangeTypeParamTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

#pragma mark - Getters and Setters

- (BOOL)isEditingFrom
{
    return [self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_IsEditingFromKey] boolValue];
}

- (void)setIsEditingFrom:(BOOL)isEditingFrom
{
    self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_IsEditingFromKey] = @(isEditingFrom);
}

- (BOOL)typesExpanded
{
    return [self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_TypesExpandedKey] boolValue];
}

- (void)setTypesExpanded:(BOOL)typesExpanded
{
    self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_TypesExpandedKey] = @(typesExpanded);
}

- (BOOL)dateExpanded
{
    return [self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_DateExpandedKey] boolValue];
}

- (void)setDateExpanded:(BOOL)dateExpanded
{
    self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_DateExpandedKey] = @(dateExpanded);
}

- (INVParameterType)fromSelectedType
{
    return [self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_FromSelectedTypeKey] integerValue];
}

- (void)setFromSelectedType:(INVParameterType)fromSelectedType
{
    self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_FromSelectedTypeKey] = @(fromSelectedType);
}

- (INVParameterType)toSelectedType
{
    return [self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_ToSelectedTypeKey] integerValue];
}

- (void)setToSelectedType:(INVParameterType)toSelectedType
{
    self.actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_ToSelectedTypeKey] = @(toSelectedType);
}

- (NSString *)_valueString:(id)value
{
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

- (NSString *)fromValueString
{
    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]])
        return nil;

    return [self _valueString:self.actualParamDictionary[INVActualParamValue][@"from"][@"value"]];
}

- (NSString *)toValueString
{
    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]])
        return nil;

    return [self _valueString:self.actualParamDictionary[INVActualParamValue][@"to"][@"value"]];
}

- (NSArray *)fromTypes
{
    return self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)][@"from_type"];
}

- (NSArray *)toTypes
{
    return self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)][@"to_type"];
}

- (NSDictionary *)fromTypeConstraints
{
    return self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)][@"from_constraints"];
}

- (NSDictionary *)toTypeConstraints
{
    return self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)][@"to_constraints"];
}

#pragma mark - Content Management

- (void)updateUI
{
    NSDictionary *constraints = self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)];

    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]]) {
        self.actualParamDictionary[INVActualParamValue] = [@{
            @"from" : [@{@"value" : [NSNull null]} mutableCopy],
            @"to" : [@{@"value" : [NSNull null]} mutableCopy]
        } mutableCopy];

        if (constraints[@"from_unit"]) {
            self.actualParamDictionary[INVActualParamValue][@"from"][@"unit"] = [NSNull null];
        }

        if (constraints[@"to_unit"]) {
            self.actualParamDictionary[INVActualParamValue][@"to"][@"unit"] = [NSNull null];
        }
    }

    self.parameterNameLabel.text = self.actualParamDictionary[INVActualParamDisplayName];

    self.fromValueField.text = self.fromValueString;
    self.toValueField.text = self.toValueString;

    self.fromLabel.text = constraints[@"from_display"];
    self.toLabel.text = constraints[@"to_display"];

    self.fromUnitContainerView.hidden = NO;
    self.toUnitContainerView.hidden = NO;

    [self.fromUnitButton removeConstraint:self.fromUnitCollapseConstraint];
    [self.toUnitButton removeConstraint:self.toUnitCollapseConstraint];

    id fromUnit = self.actualParamDictionary[INVActualParamValue][@"from"][@"unit"];
    if (fromUnit == nil) {
        self.fromUnitContainerView.hidden = YES;
        [self.fromUnitContainerView addConstraint:self.fromUnitCollapseConstraint];
    }
    else if ([fromUnit isKindOfClass:[NSNull class]]) {
        [self.fromUnitButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
    }
    else {
        [self.fromUnitButton setTitle:fromUnit forState:UIControlStateNormal];
    }

    id toUnit = self.actualParamDictionary[INVActualParamValue][@"to"][@"unit"];
    if (toUnit == nil) {
        self.toUnitContainerView.hidden = YES;
        [self.toUnitContainerView addConstraint:self.toUnitCollapseConstraint];
    }
    else if ([toUnit isKindOfClass:[NSNull class]]) {
        [self.toUnitButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
    }
    else {
        [self.toUnitButton setTitle:toUnit forState:UIControlStateNormal];
    }

    [self.fromTypeButton setTitle:INVParameterTypeToString(self.fromSelectedType) forState:UIControlStateNormal];
    [self.toTypeButton setTitle:INVParameterTypeToString(self.toSelectedType) forState:UIControlStateNormal];

    if (self.actualParamDictionary[INVActualParamError]) {
        self.errorContainerView.hidden = NO;
        [self.errorContainerView removeConstraint:self.errorContainerCollapseLayoutConstraint];

        self.errorMessageLabel.text = self.actualParamDictionary[INVActualParamError];
    }
    else {
        self.errorContainerView.hidden = YES;
        [self.errorContainerView addConstraint:self.errorContainerCollapseLayoutConstraint];
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

    if (_actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_FromSelectedTypeKey] == nil) {
        _actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_FromSelectedTypeKey] = [self.fromTypes firstObject];
    }

    if (_actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_ToSelectedTypeKey] == nil) {
        _actualParamDictionary[INVRuleInstanceRangeTypeParamTableViewCell_ToSelectedTypeKey] = [self.toTypes firstObject];
    }

    [self updateUI];
}

#pragma mark - IBActions

- (void)fromValueTextChanged:(id)sender
{
    NSMutableDictionary *newValue = [self.actualParamDictionary[INVActualParamValue] mutableCopy];
    newValue[@"from"][@"value"] = self.fromValueField.text;

    [self handleNewValue:newValue];
}

- (void)toValueTextChanged:(id)sender
{
    NSMutableDictionary *newValue = [self.actualParamDictionary[INVActualParamValue] mutableCopy];
    newValue[@"to"][@"value"] = self.toValueField.text;

    [self handleNewValue:newValue];
}

- (IBAction)toggleTypesPicker:(id)sender
{
    self.isEditingFrom = (sender == self.fromTypeButton);

    [self.fromValueField resignFirstResponder];
    [self.toValueField resignFirstResponder];

    self.dateExpanded = NO;
    self.typesExpanded = !self.typesExpanded;

    [self reloadCell];
}

#pragma mark - Helper Methods

- (void)reloadCell
{
    [self updateUI];

    UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)handleNewValue:(NSDictionary *)newValue
{
    NSError *error = [[INVRuleParameterParser instance] isValueValid:newValue
                                                   forAnyTypeInArray:self.actualParamDictionary[INVActualParamType]
                                                     withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]];

    if (error) {
        self.actualParamDictionary[INVActualParamError] = [error localizedDescription];
        [self updateUI];

        UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
    else {
        self.actualParamDictionary[INVActualParamValue] = newValue;
        [self.actualParamDictionary removeObjectForKey:INVActualParamError];
        [self updateUI];

        UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.isEditingFrom) {
        return self.fromTypes.count;
    }

    return self.toTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.isEditingFrom) {
        return INVParameterTypeToString([self.fromTypes[row] integerValue]);
    }

    return INVParameterTypeToString([self.toTypes[row] integerValue]);
}

@end
