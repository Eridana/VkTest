//
//  Group.h
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * groupAvatarUrl;
@property (nonatomic, retain) NSNumber * idUnique;
@property (nonatomic, retain) NSString * groupName;

@end
