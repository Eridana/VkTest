//
//  DetailViewController.m
//  vkTest
//
//  Created by Женя Михайлова on 02.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "Attachment.h"
#import "Post.h"
#import "User.h"
#import "Group.h"
#import "ImageViewController.h"

@interface DetailViewController ()
{
    Post *post;
    UIFont *textFont;
}
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    textFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.pagingView.delegate = self;
    self.pagingView.gapBetweenPages = 1;
    
    [self showPostData];
    [self.pagingView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
     self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.contentSize.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPost:(Post *)selectedPost
{
    post = selectedPost;
}

- (void)showPostData
{
    self.titleLabel.text = post.postTitle;
    if (post.postText.length > 0) {
        NSString *text = post.postText;
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: textFont}];
        self.postTextView.text = text;
        self.postTextView.frame = CGRectMake(self.postTextView.frame.origin.x, self.postTextView.frame.origin.y, self.postTextView.frame.size.width, textSize.height);
    }
    if (post.postUser) {
        self.userNameLabel.text = post.postUser.userName;
        [self.avatarImgView sd_setImageWithURL:[NSURL URLWithString:post.postUser.userAvatarUrl]];
    }
    if (post.postGroup) {
        self.userNameLabel.text = post.postGroup.groupName;
        [self.avatarImgView sd_setImageWithURL:[NSURL URLWithString:post.postGroup.groupAvatarUrl]];
    }
    
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:post.date];
    self.dateLabel.text = dateString;
    
    if (post.attachments.count == 0) {
        self.imageHeightConstraint.constant = 0;
        self.pagingView.hidden = YES;
    }
    else {
        self.pagingView.hidden = NO;
    }
}

- (IBAction)imageTap:(id)sender
{
    [self performSegueWithIdentifier:@"showImages" sender:self];
}

#pragma mark - ATPagingViewDelegate

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView
{
    return [post.attachments count];
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index
{
    Attachment *photo = [[post.attachments allObjects] objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:photo.attachmentUrl];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:pagingView.frame];
    
    [imageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
    }];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    imageTap.numberOfTapsRequired = 1;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:imageTap];
    
    return imageView;
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImages"]) {
        ImageViewController *ivc = segue.destinationViewController;
        NSArray *urls = [[post.attachments allObjects] valueForKey:@"attachmentUrl"];
        [ivc setImagesList:urls andSelectedIndex:(int)self.pagingView.currentPageIndex];
    }
}


@end
