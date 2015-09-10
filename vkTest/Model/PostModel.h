//
//  PostModel.h
//  vkTest
//
//  Created by Женя Михайлова on 07.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PostModelDelegate <NSObject>
- (void)getPostsSuccessWithNextFrom:(NSString *)nextFrom;
- (void)getPostsDidFailWithError;
@end

@interface PostModel : NSObject
@property (weak, nonatomic) id<PostModelDelegate> delegate;
- (void)getPostsWithNextFrom:(NSString *)nextFrom;
- (void)getPostsToEndDate:(double)unixTimeDate;
- (NSFetchRequest *)getPostsRequest;
@end
