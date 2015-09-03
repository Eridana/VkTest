//
//  ZoomImageView.m
//  gasoil
//
//  Created by Женя Михайлова on 11.06.15.
//  Copyright (c) 2015 mobigear. All rights reserved.
//

#import "ZoomImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#define k480Resolution          ([[UIScreen mainScreen] bounds].size.height == 480)
#define k568Resolution          ([[UIScreen mainScreen] bounds].size.height == 568)
#define kMaximumZoomScale 2.0
#define kAlertViewButtonInex_YES 1

@interface ZoomImageView()
- (void)loadImageWithURL:(NSString *)imageURL;
@end

@implementation ZoomImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        CGRect newFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _zoomingImageView = [[NWZoomingImageView alloc] initWithFrame:newFrame];
        _zoomingImageView.zoomingDelegate = self;_zoomingImageView.zoomingDelegate = self;
        [_zoomingImageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_zoomingImageView];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showSavePhotoAlertView:)];
        _zoomingImageView.userInteractionEnabled = YES;
        _zoomingImageView.contentMode = UIViewContentModeCenter;
        [_zoomingImageView addGestureRecognizer:longPress];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        _image = image;
        _zoomingImageView.image = _image;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)imageURL
{
    self = [self initWithFrame:frame];
    if (self) {
        _imageURL = imageURL;
        [self startLoading];
    }
    return self;
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
    indicator.center = self.center;
    [indicator startAnimating];
    [self addSubview:indicator];
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self viewWithTag:1002] removeFromSuperview];
    });
}

- (void)startLoading
{
    if (_image != nil) {
        _zoomingImageView.image = _image;
    }
    else {
        [self loadImageWithURL:_imageURL];
    }
}

# pragma mark - Save image

- (void)savePhoto
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(_zoomingImageView.image, nil, nil, nil);
    });
}

- (void)showSavePhotoAlertView:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Отмена"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:
                                @"Сохранить изображение?",
                                nil];
        popup.tag = 1;
        [popup showInView:self];
    }
}


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self savePhoto];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - image loading

- (void)loadImageWithURL:(NSString *)imageURL intoImageView:(NWZoomingImageView *)imageView
{
    if ([_imageURL length] == 0) {
        return;
    }
    NSLog(@"loadImageWithURL intoImageView START LOADING");
    [self showActivityIndicator];

    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageURL]];
    UIImage *img = [UIImage imageWithData:data];
    [self hideActivityIndicator];
    [imageView setImage:img];
    
    /*
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setImageWithURL:[NSURL URLWithString: imageURL]
            placeholderImage:nil
                     options:0
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         [self hideActivityIndicator];
         NSLog(@"loadImageWithURL intoImageView IMAGE LOADED");
         [imageView setImage:image];
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    */
}

- (void)loadImageWithURL:(NSString *)imageURL
{
    if ([_imageURL length] == 0) {
        return;
    }

    [self showActivityIndicator];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageURL]];
    UIImage *img = [UIImage imageWithData:data];
    [self hideActivityIndicator];
    [_zoomingImageView setImage:img];
    
    /* работает через раз почему-то
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        NSLog(@"loadImageWithURL IMAGE LOADED");
        [self hideActivityIndicator];
        [_zoomingImageView setImage:image];
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     */
}

#pragma mark NWZoomingImageViewDelegate

- (void)closeImageView
{
    [_zoomImageViewDelegate closeImageView];
}

@end
