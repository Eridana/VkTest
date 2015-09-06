//
//  Post.h
//  vkTest
//
//  Created by Женя Михайлова on 06.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * idUnique;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * postText;
@property (nonatomic, retain) NSString * postTitle;
@property (nonatomic, retain) NSData * postImages;
@property (nonatomic, retain) NSString * userImageUrl;

@end
