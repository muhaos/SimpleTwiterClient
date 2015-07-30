//
//  TweetsStore.h
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const kTweetsPerPage = 20;


@interface TweetsStore : NSObject

+ (TweetsStore *)sharedStore;

- (void) updateTimelineTweetsWithLastTweetID:(NSNumber*)lastTweetID completionBlock:(void(^)(NSError* error)) block;



@end
