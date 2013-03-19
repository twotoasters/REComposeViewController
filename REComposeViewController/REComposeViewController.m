//
// REComposeViewController.m
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

#import "REComposeViewController.h"
#import "REComposeView.h"
#import "REComposeSheetView.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static const CGFloat kDefaultCornerRadius = 10.0f;

@interface REComposeViewController ()
@property (nonatomic, strong, readonly) REComposeView *composeView;
@end

@implementation REComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _attachmentImage = [UIImage imageNamed:@"REComposeViewController.bundle/URLAttachment"];
        _cornerRadius = kDefaultCornerRadius;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    self.view = [[REComposeView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.composeView.cornerRadius = self.cornerRadius;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Property setters

- (void)setText:(NSString *)text
{
    _text = [text copy];
    if (self.isViewLoaded) {
        self.composeView.sheetView.textView.text = _text;
    }
}

- (void)setAttachment:(BOOL)attachment
{
    _attachment = attachment;
    if (self.isViewLoaded) {
        self.composeView.sheetView.attachmentView.hidden = !_attachment;
        [self.composeView setNeedsLayout];
    }
}

- (void)setAttachmentImage:(UIImage *)attachmentImage
{
    _attachmentImage = attachmentImage;
    if (self.isViewLoaded) {
        self.composeView.sheetView.attachmentImageView.image = _attachmentImage;
    }
}

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    _cornerRadius = cornerRadius;
    if (self.isViewLoaded) {
        self.composeView.cornerRadius = _cornerRadius;
    }
}

#pragma mark - Notification handler

- (void)textViewTextDidChange:(NSNotification *)notification
{
    _text = [self.composeView.sheetView.textView.text copy];
}

#pragma mark - Private

- (REComposeView *)composeView
{
    return (REComposeView *)self.view;
}

- (void)presentSheetViewAnimated:(BOOL)animated
{
    self.composeView.sheetView = [[REComposeSheetView alloc] initWithFrame:self.view.bounds];
    self.composeView.sheetView.attachmentImageView.image = self.attachmentImage;
    self.composeView.sheetView.attachmentView.hidden = !self.attachment;
    self.composeView.sheetView.textView.text = self.text;
    [self.composeView.sheetView.navigationBar setItems:@[self.navigationItem] animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.composeView.sheetView.textView];

    [self.composeView layoutIfNeeded];
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:animated];
    [self.composeView.sheetView.textView becomeFirstResponder];
    [UIView setAnimationsEnabled:animationsEnabled];

    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.25;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        NSArray *viewsToAnimate = @[ self.composeView.sheetView, self.composeView.shadowView, self.composeView.paperClipView ];
        for (UIView *view in viewsToAnimate) {
            CGPoint position = view.layer.position;
            position.y += CGRectGetHeight(self.composeView.bounds);
            animation.fromValue = [NSValue valueWithCGPoint:position];
            [view.layer addAnimation:animation forKey:@"position"];
        }
    }
}

- (void)dismissSheetViewAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:animated];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [UIView setAnimationsEnabled:animationsEnabled];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn)
                         animations:^{
                             NSArray *viewsToAnimate = @[ self.composeView.sheetView, self.composeView.shadowView, self.composeView.paperClipView ];
                             for (UIView *view in viewsToAnimate) {
                                 CGPoint center = view.center;
                                 center.y += CGRectGetHeight(self.composeView.bounds);
                                 view.center = center;
                             }
                         }
                         completion:^(BOOL finished) {
                             if (completion) {
                                 completion();
                             }
                         }];
    } else {
        self.composeView.sheetView = nil;
        if (completion) {
            completion();
        }
    }
}

@end


static char kPresentedComposeViewControllerKey;

@implementation UIViewController (REComposeViewControllerPresentation)

- (REComposeViewController *)presentedComposeViewController
{
    return objc_getAssociatedObject(self, &kPresentedComposeViewControllerKey);
}

- (void)setPresentedComposeViewController:(REComposeViewController *)viewController
{
    objc_setAssociatedObject(self, &kPresentedComposeViewControllerKey, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)presentComposeViewController:(REComposeViewController *)viewController animated:(BOOL)animated
{
    if (self.presentedComposeViewController) {
        // exception
    }

    [self addChildViewController:viewController];
    self.presentedComposeViewController = viewController;

    viewController.view.frame = self.view.bounds;
    viewController.view.autoresizingMask = (  UIViewAutoresizingFlexibleWidth
                                            | UIViewAutoresizingFlexibleHeight);
    CGFloat targetAlpha = viewController.view.alpha;
    viewController.view.alpha = 0.0f;
    viewController.view.layer.shouldRasterize = YES;
    viewController.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    [self.view addSubview:viewController.view];

    [UIView animateWithDuration:animated ? 0.3 : 0.0
                     animations:^{
                         viewController.view.alpha = targetAlpha;
                     }
                     completion:^(BOOL finished) {
                         viewController.view.layer.shouldRasterize = NO;
                         [viewController didMoveToParentViewController:self];
                         [viewController presentSheetViewAnimated:animated];
                     }];
}

- (void)dismissComposeViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self.presentedComposeViewController willMoveToParentViewController:nil];

    [self.presentedComposeViewController dismissSheetViewAnimated:animated
                                                       completion:^{
                                                           CGFloat originalAlpha = self.presentedComposeViewController.view.alpha;
                                                           self.presentedComposeViewController.view.layer.shouldRasterize = YES;
                                                           self.presentedComposeViewController.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];

                                                           [UIView animateWithDuration:animated ? 0.3 : 0.0
                                                                            animations:^{
                                                                                self.presentedComposeViewController.view.alpha = 0.0f;
                                                                            }
                                                                            completion:^(BOOL finished) {
                                                                                self.presentedComposeViewController.view.alpha = originalAlpha;
                                                                                self.presentedComposeViewController.view.layer.shouldRasterize = NO;
                                                                                [self.presentedComposeViewController.view removeFromSuperview];
                                                                                [self.presentedComposeViewController removeFromParentViewController];
                                                                                self.presentedComposeViewController = nil;

                                                                                if (completion) {
                                                                                    completion();
                                                                                }
                                                                            }];
                                                       }];
}

@end
