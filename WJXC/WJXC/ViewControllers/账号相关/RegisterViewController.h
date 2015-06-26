//
//  RegisterViewController.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  注册
 */

#import "MyViewController.h"

@interface RegisterViewController : MyViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *securityTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;

@property (strong, nonatomic) IBOutlet UILabel *secondsLabel;

@property (strong, nonatomic) IBOutlet UIButton *codeButton;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;

- (IBAction)clickToSecurityCode:(id)sender;
- (IBAction)clickToRegister:(id)sender;
- (IBAction)tapToHiddenKeyboard:(id)sender;

@end
