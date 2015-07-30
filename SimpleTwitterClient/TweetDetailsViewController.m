//
//  TweetDetailsViewController.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import <TwitterKit/TwitterKit.h>

static NSInteger const kTopMargin = 30;
static NSInteger const kSideMargin = 10;


@interface TweetDetailsViewController () <TWTRTweetViewDelegate>

@end

@implementation TweetDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [TWTRTweetView appearance].theme = TWTRTweetViewThemeDark;
    
    TWTRTweetView* tweetView = [[TWTRTweetView alloc] initWithTweet:self.trTweet style:TWTRTweetViewStyleRegular];
    tweetView.delegate = self;
    
    [self.view addSubview:tweetView];
    
    float tweetWidth = self.view.frame.size.width - kSideMargin * 2;
    CGSize s = [tweetView sizeThatFits:CGSizeMake(tweetWidth, CGFLOAT_MAX)];
    tweetView.frame = CGRectMake(kSideMargin, kTopMargin, tweetWidth, s.height);
}


- (IBAction)closeTapped:(id)sender {
    [TWTRTweetView appearance].theme = TWTRTweetViewThemeLight;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)tweetView:(TWTRTweetView *)tweetView didTapURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
