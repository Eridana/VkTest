//
//  PostModel.h
//  vkTest
//
//  Created by Женя Михайлова on 07.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PostModelDelegate <NSObject>
- (void)getPostsSuccess;
- (void)getPostsDidFailWithError;
@end

@interface PostModel : NSObject
@property (weak, nonatomic) id<PostModelDelegate> delegate;
- (void)getPostsWithOffset:(int)offset andCount:(int)count;
- (NSFetchRequest *)getPostsRequest;
@end
