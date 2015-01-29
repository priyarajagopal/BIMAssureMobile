//
//  UITextField.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIResponder (IBHelpers)

// This is a 'cheat' to allow us to hook up these selectors to actions
// in our storyboard without having to write additional code.
- (IBAction)becomeFirstResponder;
- (IBAction)resignFirstResponder;

@end
