//
//  VkAccountData.h
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeychainItemWrapper;

@interface VkAccountData : NSObject

- (NSString *)getAccessTokenFromKeychain;
- (NSString *)getUserIDFromKeychain;
- (void)writeAccessTokenToKeychain:(NSString *)accessToken withUserId:(NSString *)userID;
- (void)resetKeychains;
@end
