//
//  UIViewController+ShowAlertView.h
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowAlertView)

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)showAlertWithMessage:(NSString *)message;

@end
