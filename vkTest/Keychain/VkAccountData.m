//
//  VkAccountData.m
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "VkAccountData.h"
#import "KeychainItemWrapper.h"

#define kAccessTokenKeychain    @"VKAccessTokenKey"
#define kUserIdKeychain         @"VKUserID"

#define kAccountName @"ru.jane.vkTest.vkAccount"
#define kServiceName @"ru.jane.vkTest.vkService"

@interface VkAccountData()
{
    KeychainItemWrapper *accessTokenKeychain;
}
@end

@implementation VkAccountData

- (id)init
{
    self = [super init];
    if (self) {
        accessTokenKeychain = [[KeychainItemWrapper alloc] initWithIdentifier:kAccessTokenKeychain accessGroup:@"9377R37M3Q.ru.jane.vkTest"];
        [accessTokenKeychain setObject:@"ru.jane.vkTest.vkService" forKey:(__bridge id)kSecAttrService];
        [accessTokenKeychain setObject:@"ru.jane.vkTest.vkAccount" forKey:(__bridge id)kSecAttrAccount];
    }
    return self;
}

- (NSString *)getAccessTokenFromKeychain
{
    NSData *tokenData = (NSData *)[accessTokenKeychain objectForKey:(__bridge id)kSecValueData];
    NSString *token = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
    return token;
}

- (NSString *)getUserIDFromKeychain
{
    NSString *userId = [accessTokenKeychain objectForKey:(__bridge id)kSecAttrAccount];
    return userId;
}

- (void)writeAccessTokenToKeychain:(NSString *)accessToken withUserId:(NSString *)userID
{
    @synchronized(accessTokenKeychain) {
        NSData *tokenData = [accessToken dataUsingEncoding:NSUTF8StringEncoding];
        [accessTokenKeychain setObject:tokenData forKey:(__bridge id)kSecValueData];
        [accessTokenKeychain setObject:userID forKey:(__bridge id)kSecAttrAccount];
    }
}

- (void)resetKeychains
{
    [accessTokenKeychain resetKeychainItem];}

@end
