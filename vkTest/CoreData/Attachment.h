//
//  Attachment.h
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Attachment : NSManagedObject

@property (nonatomic, retain) NSString * attachmentUrl;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * postId;

@end
