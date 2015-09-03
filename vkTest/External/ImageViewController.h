//
//  ImageViewController.h
//  vkTest
//
//  Created by Женя Михайлова on 03.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NWZoomingImageView.h"
#import "ATPagingView.h"
#import "ZoomImageView.h"

@interface ImageViewController : UIViewController <ATPagingViewDelegate, ZoomImageViewDelegate>
@property (assign, nonatomic) BOOL showImagesAtPaths;
@property (strong, nonatomic) IBOutlet ATPagingView *pagingView;
- (void)setImageUrl:(NSString *)theImageUrl andImagesList:(NSArray *)images;
@end
