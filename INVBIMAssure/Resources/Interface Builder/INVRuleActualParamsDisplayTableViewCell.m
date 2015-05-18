//
//  INVRuleActualParamsDisplayTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 4/8/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleActualParamsDisplayTableViewCell.h"

@interface INVRuleActualParamsDisplayTableViewCell ()
@property(weak, nonatomic) IBOutlet UILabel *ruleInstanceKeyLabel;
@property(weak, nonatomic) IBOutlet UITextField *ruleInstanceValueTextField;
@property(readonly, nonatomic) NSString *valueString;

@end
@implementation INVRuleActualParamsDisplayTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
    self.ruleInstanceKeyLabel.text = @"";
    self.ruleInstanceValueTextField.text = @"";

}


#pragma mark accessors
-(void)setNameField:(id)nameField {
    _nameField = nameField;
    self.ruleInstanceKeyLabel.text = _nameField;
    [self setNeedsLayout];

}


-(void)setValueField:(id)valueField {
    _valueField = valueField;
    self.ruleInstanceValueTextField.text =self.valueString;;
    
    if (self.textTintColor) {
        [self.ruleInstanceValueTextField setTextColor:self.textTintColor];
        [self.ruleInstanceKeyLabel setTextColor:self.textTintColor];
    } else {
        [self.ruleInstanceValueTextField setTextColor:[UIColor whiteColor]];
        [self.ruleInstanceKeyLabel setTextColor:[UIColor whiteColor]];
    }

    [self setNeedsLayout];
    
}


- (NSString *)valueString {
  id value = _valueField;


  if (value == nil || [value isKindOfClass:[NSNull class]]) return @"";

  if ([value isKindOfClass:[NSString class]]) return value;

  if ([value isKindOfClass:[NSNumber class]]) return [value stringValue];

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

  if ([value isKindOfClass:[NSArray class]]) {
    return [(NSArray *)value componentsJoinedByString:@","];
  }

  if ([value isKindOfClass:[NSDictionary class]]) {
      NSArray* valueDicts = [value valueForKeyPath: @"@allValues"];
      NSArray *values = [valueDicts valueForKeyPath: @"@unionOfArrays.@allValues"];
    
      return [values componentsJoinedByString:@","];
  }
  [NSException raise:NSInvalidArgumentException
              format:@"Unknown class of value %@", value];

  return value;
}
@end
