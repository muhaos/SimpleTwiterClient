//
//  TweetDetailsViewController.h
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWTRTweet;

@interface TweetDetailsViewController : UIViewController

@property (nonatomic, strong) TWTRTweet* trTweet;

@end
