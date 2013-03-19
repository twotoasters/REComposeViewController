//
//  RootViewController.m
//  REComposeViewControllerExample
//
//  Created by Roman Efimov on 10/19/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "RootViewController.h"
#import "REComposeViewController.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"REComposeViewController";
	self.view.backgroundColor = [UIColor whiteColor];

    UIButton *socialExampleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    socialExampleButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2.0f, 20, 200, 40);
    socialExampleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [socialExampleButton addTarget:self action:@selector(socialExampleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [socialExampleButton setTitle:@"Some social network" forState:UIControlStateNormal];
    [self.view addSubview:socialExampleButton];

    UIButton *tumblrExampleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tumblrExampleButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2.0f, 70, 200, 40);
    tumblrExampleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tumblrExampleButton addTarget:self action:@selector(tumblrExampleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [tumblrExampleButton setTitle:@"Tumblr" forState:UIControlStateNormal];
    [self.view addSubview:tumblrExampleButton];

    UIButton *foursquareExampleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    foursquareExampleButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2.0f, 120, 200, 40);
    foursquareExampleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [foursquareExampleButton addTarget:self action:@selector(foursquareExampleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [foursquareExampleButton setTitle:@"Foursquare" forState:UIControlStateNormal];
    [self.view addSubview:foursquareExampleButton];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark - Button actions

- (void)socialExampleButtonPressed
{
    REComposeViewController *composeViewController = [REComposeViewController new];
    composeViewController.title = @"Social Network";
    composeViewController.attachment = NO;
    composeViewController.text = @"Test";
    composeViewController.cornerRadius = 2.0f;
    composeViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    composeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    [self presentComposeViewController:composeViewController animated:YES];
}

- (void)tumblrExampleButtonPressed
{
    REComposeViewController *composeViewController = [REComposeViewController new];
    composeViewController.title = @"Tumblr";
    composeViewController.attachment = YES;
    composeViewController.attachmentImage = [UIImage imageNamed:@"Flower.jpg"];
    composeViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    composeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    [self presentComposeViewController:composeViewController animated:NO];
}

- (void)foursquareExampleButtonPressed
{
    REComposeViewController *composeViewController = [REComposeViewController new];
    composeViewController.attachment = YES;
    composeViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    composeViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foursquare-logo"]];
    titleImageView.frame = CGRectMake(0, 0, 110, 30);
    composeViewController.navigationItem.titleView = titleImageView;

    // UIApperance setup
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    composeViewController.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:60/255.0 green:165/255.0 blue:194/255.0 alpha:1];
    composeViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:29/255.0 green:118/255.0 blue:143/255.0 alpha:1];

    [self presentComposeViewController:composeViewController animated:YES];
}

- (void)cancelButtonTapped
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self dismissComposeViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonTapped
{
    NSLog(@"%s, text: %@", __PRETTY_FUNCTION__, self.presentedComposeViewController.text);
    [self dismissComposeViewControllerAnimated:YES completion:^{ NSLog(@"done"); }];
}

@end
