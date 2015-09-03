//
//  ZoomImageView.h
//  gasoil
//
//  Created by Женя Михайлова on 11.06.15.
//  Copyright (c) 2015 mobigear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWZoomingImageView.h"

@protocol ZoomImageViewDelegate;

@interface ZoomImageView : UIView <NWZoomingImageViewDelegate, UIActionSheetDelegate>
{
    UIImage     *_image;
    UIImage     *_placeholder;
    NSString    *_imageURL;
    NSString    *_placeholderImageName;
    NWZoomingImageView      *_zoomingImageView;
}

@property (assign, nonatomic) id <ZoomImageViewDelegate> zoomImageViewDelegate;

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)imageURL;

@end


@protocol ZoomImageViewDelegate

@required
- (void)closeImageView;

@end