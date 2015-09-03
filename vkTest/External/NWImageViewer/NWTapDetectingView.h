//
//  NWTapdetectingView.h
//  NWImageViewer
//
//  Created by Tom Nys on 04/05/13.
//  Copyright (c) 2013 Tom Nys. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NWTapDetectingViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapInLocation:(CGPoint)location;
- (void)view:(UIView *)view doubleTapInLocation:(CGPoint)location;

@end

@interface NWTapDetectingView : UIView

@property (nonatomic, weak) id <NWTapDetectingViewDelegate> tapDelegate;

@end
