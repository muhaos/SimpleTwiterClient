//
//  TweetsStore.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "TweetsStore.h"
#import <MagicalRecord/MagicalRecord.h>
#import "ArchivedTweet.h"
#import <TwitterKit/TwitterKit.h>


@implementation TweetsStore

+ (TweetsStore *)sharedStore
{
    static TweetsStore *_inst = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _inst = [[TweetsStore alloc] init];
    });
    return _inst;
}


- (void) postTweetWithText:(NSString*)text completionBlock:(void(^)(NSError* error)) block
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/update.json";
    NSDictionary *params = @{@"status":text};
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"POST" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError == nil) {

            // saving new tweet into db
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                NSError *jsonError;
                NSDictionary *tweetJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                ArchivedTweet* archivedTweet = [ArchivedTweet MR_createEntityInContext:localContext];
                archivedTweet.tweetID = tweetJSON[@"id"];
                archivedTweet.tweetData = data;
             } completion:^(BOOL contextDidSave, NSError *error) {
                 block(error);
             }];
            
        }
        else {
            block(connectionError);
        }
        
    }];
}


- (void) updateTimelineTweetsWithLastTweetID:(NSNumber*)lastTweetID completionBlock:(void(^)(NSError* error)) block
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSMutableDictionary *params = [@{@"count":[NSString stringWithFormat:@"%d", kTweetsPerPage]} mutableCopy];
    if (lastTweetID != nil) params[@"max_id"] = lastTweetID.stringValue;
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    [[[Twitter sharedInstance] APIClient] sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            [self mergeTweetsIntoDB:data clearDB:(lastTweetID == nil) completionBlock:block];
        }
        else {
            block(connectionError);
        }
    }];
}


- (void) mergeTweetsIntoDB:(NSData*)tweetsData  clearDB:(BOOL)needClear completionBlock:(void(^)(NSError* error)) block
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSError *jsonError;
        NSArray *tweets = [NSJSONSerialization JSONObjectWithData:tweetsData options:0 error:&jsonError];

        if (needClear) {
            // if we fetch first page we need to delete all old tweets and fill DB with new tweets
            // if we fetch second or third page and so on then just append new tweets to exising ones
            [ArchivedTweet MR_truncateAllInContext:localContext];
        }
        
        for (NSDictionary* tweetJSON in tweets) {
            ArchivedTweet* archivedTweet = nil;
            archivedTweet = [ArchivedTweet MR_findFirstByAttribute:@"tweetID" withValue:tweetJSON[@"id"] inContext:localContext];
            if (archivedTweet == nil) {
                archivedTweet = [ArchivedTweet MR_createEntityInContext:localContext];
            }
            archivedTweet.tweetID = tweetJSON[@"id"];
            archivedTweet.tweetData = [NSJSONSerialization dataWithJSONObject:tweetJSON options:0 error:nil];
        }
    } completion:^(BOOL contextDidSave, NSError *error) {
        block(error);
    }];
}





@end
