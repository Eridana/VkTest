//
//  NewsTableViewCell.h
//  vkTest
//
//  Created by Женя Михайлова on 03.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postTextHeightConstraint;
- (void)setData:(id)data;
@end
