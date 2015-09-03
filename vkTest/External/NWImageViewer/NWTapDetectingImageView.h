//
//  NWTapDetectingImageView.h
//  NWImageViewer
//
//  Created by Tom Nys on 04/05/13.
//  Copyright (c) 2013 Tom Nys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NWTapDetectingImageViewDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)view singleTapInLocation:(CGPoint)location;
- (void)imageView:(UIImageView *)view doubleTapInLocation:(CGPoint)location;
@end

@interface NWTapDetectingImageView : UIImageView

- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;

@property (nonatomic, weak) id <NWTapDetectingImageViewDelegate> tapDelegate;

@end
