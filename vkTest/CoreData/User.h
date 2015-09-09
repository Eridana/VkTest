//
//  User.h
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * idUnique;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userAvatarUrl;

@end
