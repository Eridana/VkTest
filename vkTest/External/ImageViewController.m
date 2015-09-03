//
//  ImageViewController.m
//  vkTest
//
//  Created by Женя Михайлова on 03.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "ImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#define kMaximumZoomScale 2.0

@interface ImageViewController()
{
    BOOL closing;
    int imageIndex;
    NSString *imageURL;
    NSMutableArray *imagesUrlList;
}
@end

@implementation ImageViewController

- (void)setImageUrl:(NSString *)theImageUrl andImagesList:(NSArray *)images
{
    imageURL = theImageUrl;
    imageIndex = 0;
    if (images == nil) {
        imagesUrlList = [NSMutableArray arrayWithObject:imageURL];
    }
    else {
        imagesUrlList = [images mutableCopy];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor = Rgb2UIColor(51, 51, 51);
    [self.view addSubview:statusBarView];
    self.view.backgroundColor = [UIColor whiteColor];
    [_pagingView setFrame:self.view.frame];
    [_pagingView setBackgroundColor:[UIColor clearColor]];
    _pagingView.autoresizesSubviews = YES;
    _pagingView.delegate = self;
    _pagingView.gapBetweenPages = 1.0f;
    
    if (imageIndex != 0) {
        _pagingView.currentPageIndex = imageIndex;
    }
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_pagingView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showActivityIndicator {
    [self showActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
}

- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style {
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    indicator.frame = CGRectMake(0, 0, 30, 30);
    indicator.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    indicator.tag = 1002;
    indicator.center = self.view.center;
    [indicator startAnimating];
    [self.view addSubview:indicator];
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.view viewWithTag:1002] removeFromSuperview];
    });
}

#pragma mark - ATPagingViewDelegate

- (NSInteger)numberOfPagesInPagingView:(ATPagingView *)pagingView
{
    return [imagesUrlList count];
}

- (UIView *)viewForPageInPagingView:(ATPagingView *)pagingView atIndex:(NSInteger)index
{
    NSString *url = [imagesUrlList objectAtIndex:index];
    if (self.showImagesAtPaths == YES) {
        [self showActivityIndicator];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *img = [UIImage imageWithData:data];
        [self hideActivityIndicator];
        ZoomImageView *view = [[ZoomImageView alloc] initWithFrame:pagingView.frame withImage:img];
        view.zoomImageViewDelegate = self;
        return view;
    }
    ZoomImageView *view = [[ZoomImageView alloc] initWithFrame:pagingView.frame withImageURL:url];
    view.zoomImageViewDelegate = self;
    return view;
}

#pragma mark ZoomImageViewDelegate

- (void)closeImageView
{
    [self backButtonPressed];
}

#pragma mark - UI actions

- (void)backButtonPressed
{
    closing = YES;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

@end
