//
//  Post.h
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, NSManagedObject, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * idUnique;
@property (nonatomic, retain) NSString * postText;
@property (nonatomic, retain) NSString * postTitle;
@property (nonatomic, retain) Group *postGroup;
@property (nonatomic, retain) User *postUser;
@property (nonatomic, retain) NSSet *attachments;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(NSManagedObject *)value;
- (void)removeAttachmentsObject:(NSManagedObject *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

@end
