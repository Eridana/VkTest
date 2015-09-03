//
//  NWZoomingScrollView.h
//  NWImageViewer
//
//  Created by Tom Nys on 04/05/13.
//  Copyright (c) 2013 Tom Nys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NWZoomingImageViewDelegate <NSObject>
@optional
-(void)hideControlsAfterDelay;
-(void)cancelControlHiding;
-(void)toggleControls;

//nsrunloop
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
- (void)closeImageView;

@end

@interface NWZoomingImageView : UIScrollView

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak) id<NWZoomingImageViewDelegate> zoomingDelegate;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStye;
@end
