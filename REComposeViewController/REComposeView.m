//
//  REComposeView.m
//  REComposeViewController
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
//  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its
//  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "REComposeView.h"
#import "REComposeSheetView.h"
#import <QuartzCore/QuartzCore.h>

static UIViewAnimationOptions AnimationOptionsFromAnimationCurve(UIViewAnimationCurve animationCurve)
{
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

static const CGFloat kGradientStartRadius = 20.0f;

static const CGFloat kSheetViewMinMargin = 4.0f;
static const CGSize kSheetViewMaxSize = { 648.0f, 202.0f };

static const CGFloat kPaperClipLeftOverhang = 6.0f;
static const CGFloat kPaperClipYOffsetFromAttachmentView = 23.0f;

@interface REComposeView ()
@property (nonatomic, strong, readwrite) UIView *shadowView;
@property (nonatomic) CGRect keyboardFrame;
@end

@implementation REComposeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;

        _shadowView = [UIView new];
        _shadowView.layer.shadowOpacity = 0.7f;
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        _shadowView.hidden = YES;
        [self addSubview:_shadowView];

        UIImage *paperClipImage = [UIImage imageNamed:@"REComposeViewController.bundle/PaperClip"];
        _paperClipView = [[UIImageView alloc] initWithImage:paperClipImage];
        _paperClipView.hidden = YES;
        [self addSubview:_paperClipView];

        _keyboardFrame = CGRectMake(0.0f, CGFLOAT_MAX, 0.0f, 0.0f);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardNotificaiton:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardNotificaiton:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0f, 1.0f };
    CGFloat components[4] = { 0.0f, 0.7f,    // Start color
                              0.0f, 0.85f }; // End color
    CGColorSpaceRef grayColorspace = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(grayColorspace, components, locations, num_locations);

    CGGradientDrawingOptions options = (  kCGGradientDrawsBeforeStartLocation
                                        | kCGGradientDrawsAfterEndLocation);

    CGFloat endRadius = CGRectGetHeight(self.bounds) / 2.0f;

    CGPoint gradientCenter = self.sheetView ? self.sheetView.center : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    CGContextDrawRadialGradient(context,
                                gradient,
                                gradientCenter,
                                kGradientStartRadius,
                                gradientCenter,
                                endRadius,
                                options);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(grayColorspace);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // center the sheetView horizontally
    // also, center it between:
    //  - the lower of the top of self.bounds and the bottom of the UIStatusBar
    // and
    //  - the higher of the bottom of self.bounds and the top of the keyboard
    CGPoint center = CGPointZero;
    center.x = CGRectGetMidX(self.bounds);

    CGRect statusBarFrameInScreenCoordinates = [UIApplication sharedApplication].statusBarFrame;
    CGRect statusBarFrameInWindowCoordinates = [self.window convertRect:statusBarFrameInScreenCoordinates fromWindow:nil];
    CGRect statusBarFrameInSelfCoordinates = [self convertRect:statusBarFrameInWindowCoordinates fromView:self.window];

    CGFloat topBoundary = MAX(CGRectGetMaxY(statusBarFrameInSelfCoordinates), CGRectGetMinY(self.bounds));
    CGFloat bottomBoundary = MIN(CGRectGetMinY(self.keyboardFrame), CGRectGetMaxY(self.bounds));

    center.y = roundf((bottomBoundary + topBoundary) / 2.0f);

    self.sheetView.center = center;

    CGRect bounds = self.sheetView.bounds;
    bounds.size.width = MIN(CGRectGetWidth(self.bounds) - 2.0f * kSheetViewMinMargin, kSheetViewMaxSize.width);
    bounds.size.height = MIN(bottomBoundary - topBoundary - 2.0f * kSheetViewMinMargin, kSheetViewMaxSize.height);
    self.sheetView.bounds = bounds;

    self.shadowView.hidden = (self.sheetView == nil);
    self.paperClipView.hidden = (self.sheetView == nil || self.sheetView.attachmentView.hidden);
    if (self.sheetView) {
        self.shadowView.bounds = self.sheetView.bounds;
        self.shadowView.center = self.sheetView.center;
        self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds
                                                                      cornerRadius:self.cornerRadius].CGPath;

        center.x = CGRectGetMaxX(self.sheetView.frame) - CGRectGetWidth(self.paperClipView.bounds) / 2.0f + kPaperClipLeftOverhang;
        CGRect attachmentViewFrame = [self convertRect:self.sheetView.attachmentView.frame fromView:self.sheetView];
        center.y = CGRectGetMinY(attachmentViewFrame) + kPaperClipYOffsetFromAttachmentView;
        self.paperClipView.center = center;
    }

    [self setNeedsDisplay];
}

#pragma mark - Property setters

- (void)setSheetView:(REComposeSheetView *)sheetView
{
    [_sheetView removeFromSuperview];
    _sheetView = sheetView;
    _sheetView.layer.cornerRadius = self.cornerRadius;
    _sheetView.layer.masksToBounds = YES;
    [self insertSubview:_sheetView belowSubview:self.paperClipView];
    [self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds
                                                                  cornerRadius:_cornerRadius].CGPath;
    self.sheetView.layer.cornerRadius = _cornerRadius;
}

#pragma mark - Notification handlers

- (void)handleKeyboardNotificaiton:(NSNotification *)notification
{
    CGRect keyboardFrameInScreenCoordinates = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameInWindowCoordinates = [self.window convertRect:keyboardFrameInScreenCoordinates fromWindow:nil];
    _keyboardFrame = [self convertRect:keyboardFrameInWindowCoordinates fromView:self.window];
    [self setNeedsLayout];

    NSTimeInterval duration = MAX([[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue], 0.25);
    UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:AnimationOptionsFromAnimationCurve(animationCurve) | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ [self layoutIfNeeded]; }
                     completion:nil];
}

@end
