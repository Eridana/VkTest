//
//  PostModel.m
//  vkTest
//
//  Created by Женя Михайлова on 07.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "PostModel.h"
#import <VKSdk.h>
#import "Post.h"
#import "User.h"
#import <CoreData+MagicalRecord.h>
#import "Group.h"
#import "Attachment.h"

@implementation PostModel

- (NSFetchRequest *)getPostsRequest
{
    return [Post MR_requestAllSortedBy:@"date" ascending:NO];
}

- (void)getPostsWithOffset:(int)offset andCount:(int)count
{
    NSString *countStr = [NSString stringWithFormat:@"%d", count];
    NSString *offsetStr =[NSString stringWithFormat:@"%d", offset];
    VKRequest * getWall = [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_COUNT : countStr, VK_API_OFFSET : offsetStr, VK_API_EXTENDED: @"1"} andHttpMethod:@"GET"];
    [getWall executeWithResultBlock:^(VKResponse * response) {
//        NSLog(@"Json result: %@", response.json);
        [self savePostsToCoreDataWithJson:response.json];
        if (self.delegate && [self.delegate respondsToSelector:@selector(getPostsSuccess)]) {
            [self.delegate getPostsSuccess];
        }
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(getPostsDidFailWithError)]) {
                [self.delegate getPostsDidFailWithError];
            }
            NSLog(@"vk error: %@", error);
        }
    }];
}

- (void)savePostsToCoreDataWithJson:(NSDictionary *)json
{
    if ([json objectForKey:@"groups"]) {
        [self parseGroupsFromData:[json objectForKey:@"groups"]];
    }
    if ([json objectForKey:@"profiles"]) {
        [self parseProfilesFromData:[json objectForKey:@"profiles"]];
    }
    
    if ([json objectForKey:@"items"]) {
        NSArray *posts = [json objectForKey:@"items"];
        for (NSDictionary *dict in posts) {
            if ([dict objectForKey:@"copy_history"]) {                
                NSArray *reposts = [dict objectForKey:@"copy_history"];
                if (reposts && reposts.count > 0) {
                    [self parsePostFromDictionary:[reposts firstObject]];
                }
                else {
                    [self parsePostFromDictionary:dict];
                }
            }
        }
    }
   
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)parsePostFromDictionary:(NSDictionary *)dict
{
    NSNumber *idUnique = [NSNumber numberWithInt: [[dict objectForKey:@"id"] intValue]];
    Post *post = [Post MR_findFirstByAttribute:@"idUnique" withValue:idUnique];
    if (!post) {
        post = [Post MR_createEntity];
        post.idUnique = idUnique;
    }
    if (![[dict objectForKey:@"title"] isEqual:[NSNull null]]) {
        post.postTitle = [dict objectForKey:@"title"];
    }
    if (![[dict objectForKey:@"text"] isEqual:[NSNull null]]) {
        post.postText = [dict objectForKey:@"text"];
    }
    if (![[dict objectForKey:@"date"] isEqual:[NSNull null]]) {
        double unixTime = [[dict objectForKey:@"date"] doubleValue];
        post.date = [self getDateFromUnixtime:unixTime];
    }
    if (![[dict objectForKey:@"from_id"] isEqual:[NSNull null]]) {
        NSNumber *oid = [NSNumber numberWithInt: [[dict objectForKey:@"from_id"] intValue]];
        User *user = [User MR_findFirstByAttribute:@"idUnique" withValue:oid];
        if (user != nil) {
            post.postUser = user;
        }
        else {
            Group *group = [Group MR_findFirstByAttribute:@"idUnique" withValue:oid];
            if (group) {
                post.postGroup = group;
            }
        }
    }
    if (![[dict objectForKey:@"attachments"] isEqual:[NSNull null]]) {
        return;
    }
    
    NSArray *photos = [dict objectForKey:@"attachments"];
    for (NSMutableDictionary *dict in photos) {
        
        NSString *type = [dict objectForKey:@"type"];
        if (type && type.length > 0) {
            
            if ([type isEqualToString:@"photo"]) {
                
                if (![[dict objectForKey:@"photo"] isEqual:[NSNull null]]) {
                    
                    NSDictionary *photosDict = [dict objectForKey:@"photo"];
                    if ([photosDict objectForKey:@"photo_1280"]) {
                        
                        NSString *url = [photosDict objectForKey:@"photo_1280"];
                        Attachment *photo = [Attachment MR_findFirstByAttribute:@"attachmentUrl" withValue:url];
                        if (!photo) {
                            
                            Attachment *photo =[Attachment MR_createEntity];
                            photo.attachmentUrl = [photosDict objectForKey:@"photo_1280"];
                            [post addAttachmentsObject:photo];
                        }
                    }

                }
                
            }
        }
    }
}

- (void)parseProfilesFromData:(NSArray *)profiles
{
    for (NSDictionary *dict in profiles) {
        NSNumber *idUnique = [NSNumber numberWithInt: [[dict objectForKey:@"id"] intValue]];
        User *user = [User MR_findFirstByAttribute:@"idUnique" withValue:idUnique];
        if (!user) {
            user = [User MR_createEntity];
            user.idUnique = idUnique;
        }
        if (![[dict objectForKey:@"first_name"] isEqual:[NSNull null]]) {
            user.userName = [dict objectForKey:@"first_name"];
        }
        if (![[dict objectForKey:@"last_name"] isEqual:[NSNull null]]) {
            user.userName =[NSString stringWithFormat:@"%@ %@", user.userName, [dict objectForKey:@"last_name"]];
        }
        if (![[dict objectForKey:@"photo_100"] isEqual:[NSNull null]]) {
            user.userAvatarUrl = [dict objectForKey:@"photo_100"];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)parseGroupsFromData:(NSArray *)groups
{
    for (NSDictionary *dict in groups) {
        NSNumber *idUnique = [NSNumber numberWithInt: [[dict objectForKey:@"gid"] intValue]];
        Group *group = [Group MR_findFirstByAttribute:@"idUnique" withValue:idUnique];
        if (!group) {
            group = [User MR_createEntity];
            group.idUnique = idUnique;
        }
        if (![[dict objectForKey:@"name"] isEqual:[NSNull null]]) {
            group.groupName = [dict objectForKey:@"name"];
        }
        if (![[dict objectForKey:@"photo"] isEqual:[NSNull null]]) {
            group.groupAvatarUrl = [dict objectForKey:@"photo"];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(NSDate *)getDateFromUnixtime:(double)unixTime
{
    NSTimeInterval interval=unixTime;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return date;
}

@end
