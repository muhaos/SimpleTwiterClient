//
//  ArchivedTweet.h
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 29.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TWTRTweet;

@interface ArchivedTweet : NSManagedObject

@property (nonatomic, retain) NSNumber * tweetID;
@property (nonatomic, retain) NSData * tweetData;


@property (nonatomic, strong) TWTRTweet * trTweet;


@end
