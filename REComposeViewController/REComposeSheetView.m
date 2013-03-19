//
// REComposeSheetView.m
// REComposeViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REComposeSheetView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kNavigationBarHeight = 44.0f;
static const CGSize kAttachmentViewSize = { 84.0f, 79.0f };
static const CGFloat kAttachmentViewOriginY = 54.0f;
static const CGRect kAttachmentImageViewFrame = { 6.0f, 2.0f, 72.0f, 72.0f };
static const CGFloat kAttachmentImageViewCornerRadius = 3.0f;

static const CGFloat kLineWidth = 1.0f;
static const CGFloat kDefaultLineYOffset = -5.0f;

@interface REComposeSheetView () <UITextViewDelegate>
@end

@implementation REComposeSheetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        frame = self.bounds;
        frame.size.height = kNavigationBarHeight;
        _navigationBar = [[UINavigationBar alloc] initWithFrame:frame];
        _navigationBar.autoresizingMask = (  UIViewAutoresizingFlexibleBottomMargin
                                           | UIViewAutoresizingFlexibleWidth);
        [self addSubview:_navigationBar];

        frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(CGRectGetHeight(_navigationBar.frame), 0.0f, 0.0f, 0.0f));
        _textView = [[UITextView alloc] initWithFrame:frame];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.opaque = NO;
        _textView.font = [UIFont systemFontOfSize:21.0f];
        _textView.alwaysBounceVertical = YES;
        _textView.autoresizingMask = (  UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
        _textView.showsVerticalScrollIndicator = NO;
        _textView.delegate = self;
        [self insertSubview:_textView belowSubview:_navigationBar];

        frame = (CGRect){ (CGPoint){ CGRectGetMaxX(self.bounds) - kAttachmentViewSize.width, kAttachmentViewOriginY }, kAttachmentViewSize };
        _attachmentView = [[UIView alloc] initWithFrame:frame];
        _attachmentView.hidden = YES;
        _attachmentView.autoresizingMask = (  UIViewAutoresizingFlexibleLeftMargin
                                            | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:_attachmentView];

        _attachmentImageView = [[UIImageView alloc] initWithFrame:kAttachmentImageViewFrame];
        _attachmentImageView.layer.cornerRadius = kAttachmentImageViewCornerRadius;
        _attachmentImageView.layer.masksToBounds = YES;
        [_attachmentView addSubview:_attachmentImageView];

        UIImage *attachmentFrameImage = [UIImage imageNamed:@"REComposeViewController.bundle/AttachmentFrame"];
        UIImageView *attachmentFrameImageView = [[UIImageView alloc] initWithImage:attachmentFrameImage];
        [_attachmentView addSubview:attachmentFrameImageView];

        _lineYOffset = kDefaultLineYOffset;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineHeight = self.textView.font.lineHeight;

    if (lineHeight > 0.0f) {
        [[UIColor colorWithWhite:0.925f alpha:1.0f] setFill];

        CGRect lineRect = CGRectMake(CGRectGetMinX(self.bounds),
                                     CGRectGetMinY(self.bounds) + self.lineYOffset + lineHeight - self.textView.contentOffset.y,
                                     CGRectGetWidth(self.bounds),
                                     kLineWidth);

        while (CGRectGetMinY(lineRect) > CGRectGetMinY(self.bounds)) {
            lineRect.origin.y -= lineHeight;
        }

        while (CGRectGetMinY(lineRect) < CGRectGetMaxY(self.bounds)) {
            UIRectFill(lineRect);
            lineRect.origin.y += lineHeight;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationBar.frame),
                                           0.0f,
                                           0.0f,
                                           self.attachmentView.hidden ? 0.0f : CGRectGetMaxX(self.bounds) - CGRectGetMinX(self.attachmentView.frame));
    self.textView.frame = UIEdgeInsetsInsetRect(self.bounds, insets);
}

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setNeedsDisplay];
}

@end
