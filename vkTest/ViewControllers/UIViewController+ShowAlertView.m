//
//  UIViewController+ShowAlertView.m
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "UIViewController+ShowAlertView.h"

@implementation UIViewController (ShowAlertView)

- (void)showAlertWithMessage:(NSString *)message
{
    [self showAlertWithTitle:@"" andMessage:message];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

@end
