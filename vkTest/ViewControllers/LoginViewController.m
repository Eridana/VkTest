//
//  LoginViewController.m
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+ShowAlertView.h"
#import <VKSdk.h>
#import "VKAccountData.h"

NSString * const VK_APP_ID = @"5054958";

@interface LoginViewController () <VKSdkDelegate>
{
    VkAccountData *data;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [VKSdk initializeWithDelegate:self andAppId:VK_APP_ID];
    
    if ([VKSdk wakeUpSession] == YES) {
        [self performSegueWithIdentifier:@"showNews" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VK methods

- (IBAction)authButtonPressed:(id)sender {
    [VKSdk authorize: @[VK_PER_WALL]];
}

- (IBAction)looutButtonPressed:(id)sender {
    [VKSdk forceLogout];
    [data resetKeychain];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    VKCaptchaViewController *vkController = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vkController presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    //relogin
    [self authButtonPressed:nil];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    [self showAlertWithTitle:NSLocalizedString(@"Доступ отклонен", nil)
                  andMessage:NSLocalizedString(@"Нет прав для доступа к ВКонтакте. Отменено пользователем.", nil)];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token
{
    NSLog(@"VkSdk did accept user token");
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    [data writeAccessTokenToKeychain:newToken.accessToken withUserId:newToken.userId];
    NSLog(@"vkSdkReceivedNewToken token saved, user id = %@", newToken.userId);
    [self performSegueWithIdentifier:@"showNews" sender:self];
}

@end
