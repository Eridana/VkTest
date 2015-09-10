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

@interface PostModel()
{
    NSString *lastNextFrom;
}

@end

@implementation PostModel

- (NSFetchRequest *)getPostsRequest
{
    return [Post MR_requestAllSortedBy:@"date" ascending:NO];
}

- (void)getPostsWithNextFrom:(NSString *)nextFrom
{
    [self getPostsWithNextFrom:nextFrom andToDate:0];
}

-(void)getPostsToEndDate:(double)unixTimeDate
{
    if (unixTimeDate > 0) {
        [self getPostsWithNextFrom:@"" andToDate:unixTimeDate];
    }
}

- (void)getPostsWithNextFrom:(NSString *)nextFrom andToDate:(double)unixTimeDate
{
    NSMutableDictionary *params= [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:VK_API_EXTENDED];
//    [params setObject:@"20" forKey:VK_API_COUNT];
    
    if (nextFrom && nextFrom.length > 0) {
        [params setObject:nextFrom forKey:@"start_from"];
    }
    if (unixTimeDate > 0) {
        [params setObject:[NSNumber numberWithDouble:unixTimeDate] forKey:@"end_time"];
    }
    
    VKRequest * getWall = [VKRequest requestWithMethod:@"newsfeed.get" andParameters:params andHttpMethod:@"GET"];
    [getWall executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        [self savePostsToCoreDataWithJson:response.json];
        if (self.delegate && [self.delegate respondsToSelector:@selector(getPostsSuccessWithNextFrom:)]) {
            [self.delegate getPostsSuccessWithNextFrom:lastNextFrom];
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
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    if ([json objectForKey:@"items"]) {
        
        NSArray *posts = [json objectForKey:@"items"];
        for (NSDictionary *dict in posts) {
            
            NSString *type = [dict objectForKey:@"type"];
            if ([type isEqualToString:@"wall_photo"]) {
                
                [self parseWallPhotoFromDictionary:dict];
            }
            if ([type isEqualToString:@"post"]) {
                
                NSArray *reposts = [dict objectForKey:@"copy_history"];
                if (reposts && reposts.count > 0) {
                    
                    [self parsePostFromDictionary:[reposts firstObject]];
                }
                else {
                    
                    [self parsePostFromDictionary:dict];
                }
            }
//            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    if ([json objectForKey:@"next_from"]) {
        lastNextFrom = [json objectForKey:@"next_from"];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    NSLog(@"posts count: %ld", [Post MR_findAll].count);
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
    if ([dict objectForKey:@"source_id"] != nil) {
        [self setUserOrGroubById:[[dict objectForKey:@"source_id"] stringValue] toPost:post];
    }
    else if ([dict objectForKey:@"from_id"] != nil) {
        [self setUserOrGroubById:[[dict objectForKey:@"from_id"] stringValue] toPost:post];
    }
    if (![[dict objectForKey:@"attachments"] isEqual:[NSNull null]]) {
        NSArray *postAttachments = [dict objectForKey:@"attachments"];
        for (NSMutableDictionary *dict in postAttachments) {
            
            NSString *type = [dict objectForKey:@"type"];
            if (type && type.length > 0) {
                
                if ([type isEqualToString:@"photo"]) {
                    
                    if (![[dict objectForKey:@"photo"] isEqual:[NSNull null]]) {
                        
                        NSDictionary *photosDict = [dict objectForKey:@"photo"];
                        Attachment *photo = [self createPhotoAttachmentFromPhotoDict:photosDict];
                        if (photo) {
                            if ([photosDict objectForKey:@"title"] != nil && post.postTitle == nil) {
                                post.postTitle = [photosDict objectForKey:@"title"];
                            }
                            if ([photosDict objectForKey:@"text"] != nil && post.postText == nil) {
                                post.postText = [photosDict objectForKey:@"text"];
                            }
                            [post addAttachmentsObject:photo];
                        }
                    }
                }
                else if ([type isEqualToString:@"video"]) {
                    NSDictionary *videoDict = [dict objectForKey:@"video"];
                    if ([videoDict objectForKey:@"title"] != nil && post.postTitle == nil) {
                        post.postTitle = [videoDict objectForKey:@"title"];
                    }
                    if ([videoDict objectForKey:@"text"] != nil && post.postText == nil) {
                        post.postText = [videoDict objectForKey:@"text"];
                    }
                }
                else if ([type isEqualToString:@"link"]) {
                    if ([dict objectForKey:@"description"] && post.postText.length == 0) {
                        post.postText = [dict objectForKey:@"description"];
                    }
                    if ([dict objectForKey:@"title"] && post.postTitle.length == 0) {
                        post.postTitle = [dict objectForKey:@"title"];
                    }
                    if ([dict objectForKey:@"image_big"]) {
                        
                        NSString *url = [dict objectForKey:@"image_big"];
                        
                        Attachment *photo = [Attachment MR_findFirstByAttribute:@"attachmentUrl" withValue:url];
                        if (!photo) {
                            
                            photo = [Attachment MR_createEntity];
                            photo.attachmentUrl = url;
                        }
                        [post addAttachmentsObject:photo];
                    }
                }
            }
        }
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSNumber *)getIdFromString:(NSString *)idString
{
    NSNumber *oid = [NSNumber numberWithLong:0];
    if (idString.length > 0) {
        if ([[idString substringToIndex:1] isEqualToString:@"-"]) {
            idString = [idString substringFromIndex:1];
        }
        oid = [NSNumber numberWithLong:[idString longLongValue]];
    }
    return oid;
}

- (void)setUserOrGroubById:(NSString *)stringId toPost:(Post *)post
{
    NSNumber *oid = [self getIdFromString:stringId];
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

- (Attachment *)createPhotoAttachmentFromPhotoDict:(NSDictionary *)photosDict
{
    NSString *url = @"";
    if ([photosDict objectForKey:@"photo_1280"]) {
        url = [photosDict objectForKey:@"photo_1280"];
    }
    else if ([photosDict objectForKey:@"photo_604"]) {
        url = [photosDict objectForKey:@"photo_604"];
    }
    
    Attachment *photo = [Attachment MR_findFirstByAttribute:@"attachmentUrl" withValue:url];
    if (!photo) {
        photo = [Attachment MR_createEntity];
        photo.attachmentUrl = url;
    }
    return photo;
}

- (void)parseWallPhotoFromDictionary:(NSDictionary *)dict
{
    NSNumber *idUnique = [NSNumber numberWithInt: [[dict objectForKey:@"source_id"] intValue]];
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
    
    NSDictionary *allphotos = [dict objectForKey:@"photos"];
    if (allphotos && [allphotos objectForKey:@"items"]) {
        for (NSDictionary *photosDict in [allphotos objectForKey:@"items"]) {
            Attachment *photo = [self createPhotoAttachmentFromPhotoDict:photosDict];
            if (photo) {
                if ([photosDict objectForKey:@"title"] != nil && post.postTitle == nil) {
                    post.postTitle = [photosDict objectForKey:@"title"];
                }
                if ([photosDict objectForKey:@"text"] != nil && post.postText == nil) {
                    post.postText = [photosDict objectForKey:@"text"];
                }

                [post addAttachmentsObject:photo];
            }
        }
    }
    
    if ([dict objectForKey:@"source_id"] != nil) {
        [self setUserOrGroubById:[[dict objectForKey:@"source_id"] stringValue] toPost:post];
    }
    else if ([dict objectForKey:@"from_id"] != nil) {
        [self setUserOrGroubById:[[dict objectForKey:@"from_id"] stringValue] toPost:post];
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)parseProfilesFromData:(NSArray *)profiles
{
    for (NSDictionary *dict in profiles) {
        NSNumber *idUnique = [self getIdFromString:[[dict objectForKey:@"id"] stringValue]];
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
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)parseGroupsFromData:(NSArray *)groups
{
    for (NSDictionary *dict in groups) {
        NSNumber *idUnique = [self getIdFromString:[[dict objectForKey:@"id"] stringValue]];
        Group *group = [Group MR_findFirstByAttribute:@"idUnique" withValue:idUnique];
        if (!group) {
            group = [Group MR_createEntity];
            group.idUnique = idUnique;
        }
        if (![[dict objectForKey:@"name"] isEqual:[NSNull null]]) {
            group.groupName = [dict objectForKey:@"name"];
        }
        if (![[dict objectForKey:@"photo_100"] isEqual:[NSNull null]]) {
            group.groupAvatarUrl = [dict objectForKey:@"photo_100"];
        }
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(NSDate *)getDateFromUnixtime:(double)unixTime
{
    NSTimeInterval interval=unixTime;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return date;
}

@end
