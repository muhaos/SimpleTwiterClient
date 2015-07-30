//
//  ArchivedTweet.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 29.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "ArchivedTweet.h"
#import <TwitterKit/TwitterKit.h>



@implementation ArchivedTweet

@dynamic tweetID;
@dynamic tweetData;
@synthesize trTweet;


- (TWTRTweet*) trTweet {
    if (trTweet == nil) {
        NSError *jsonError;
        NSDictionary *tweet = [NSJSONSerialization JSONObjectWithData:self.tweetData options:0 error:&jsonError];
        trTweet = [[TWTRTweet alloc] initWithJSONDictionary:tweet];
    }
    return trTweet;
}


@end
