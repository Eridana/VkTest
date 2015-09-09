//
//  DetailViewController.h
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "ATPagingView.h"

@interface DetailViewController : UIViewController <ATPagingViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet ATPagingView *pagingView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)setPost:(Post *)selectedPost;
@end
