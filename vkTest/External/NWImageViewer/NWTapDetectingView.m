//
//  NWTapdetectingView.m
//  NWImageViewer
//
//  Created by Tom Nys on 04/05/13.
//  Copyright (c) 2013 Tom Nys. All rights reserved.
//

#import "NWTapDetectingView.h"

@implementation NWTapDetectingView

-(void)setup
{
	self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)handleSingleTap:(UIGestureRecognizer *)sender
{
    if ([self.tapDelegate respondsToSelector:@selector(view:singleTapInLocation:)])
        [self.tapDelegate view:self singleTapInLocation:[sender locationInView:self]];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)sender
{
    if ([self.tapDelegate respondsToSelector:@selector(view:doubleTapInLocation:)])
        [self.tapDelegate view:self doubleTapInLocation:[sender locationInView:self]];
}
@end
