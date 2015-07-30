//
//  TweetsViewController.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 29.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "TweetsViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "MBProgressHUD.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <MagicalRecord/MagicalRecord.h>
#import "ArchivedTweet.h"
#import "UIActionSheet+Blocks.h"
#import "AppDelegate.h"
#import "TweetsStore.h"
#import "Utils.h"



static NSString * const TweetTableReuseIdentifier = @"TweetCell";


@interface TweetsViewController () <TWTRTweetViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createTweetButton;

@property (strong, nonatomic) NSArray *tweets;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupRefreshLogic];
    [self.tableView triggerPullToRefresh];
    [self refreshTable];
}


- (void) setupViews {
    [self makeRounds:self.createTweetButton radius:5];
    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
}


- (void) setupRefreshLogic {
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [[TweetsStore sharedStore] updateTimelineTweetsWithLastTweetID:nil completionBlock:^(NSError *error) {
            if (error != nil) {
                [Utils showHUDWithText:@"Unable to update tweets." inView:weakSelf.view];
            } else {
                [weakSelf refreshTable];
            }
            [weakSelf.tableView.pullToRefreshView stopAnimating];
        }];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        // get last tweet id
        NSNumber *lowestID = [ArchivedTweet MR_aggregateOperation:@"min:"
                                                      onAttribute:@"tweetID"
                                                    withPredicate:nil];
        
        [[TweetsStore sharedStore] updateTimelineTweetsWithLastTweetID:lowestID completionBlock:^(NSError *error) {
            if (error != nil) {
                [Utils showHUDWithText:@"Unable to update tweets." inView:weakSelf.view];
            } else {
                [weakSelf refreshTable];
            }
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }];
    }];
}


- (void) refreshTable {
    self.tweets = [ArchivedTweet MR_findAllSortedBy:@"tweetID" ascending:NO];//retain cycle
    self.tableView.infiniteScrollingView.enabled = self.tweets.count >= kTweetsPerPage;
    [self.tableView reloadData];
}



- (IBAction)newTweetTapped:(UIButton *)sender {
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    __weak typeof(self) weakSelf = self;
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
        }
        else {
            [Utils showHUDWithText:@"Tweet posted." inView:weakSelf.view];
            [weakSelf.tableView triggerPullToRefresh];
        }
    }];
}



- (IBAction)settingTapped:(id)sender {
    [UIActionSheet showInView:self.view
                    withTitle:@"Setting"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:@"Logout"
            otherButtonTitles:@[]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (buttonIndex == 0) {
                             // logout
                            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                [ArchivedTweet MR_truncateAllInContext:localContext];
                            } completion:^(BOOL contextDidSave, NSError *error) {
                                [[Twitter sharedInstance] logOut];
                                [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginVC];
                            }];
                         }
                     }];
}



# pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}


- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArchivedTweet* archivedTweet = self.tweets[indexPath.row];
    TWTRTweet *tweet = archivedTweet.trTweet;
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:TweetTableReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArchivedTweet* archivedTweet = self.tweets[indexPath.row];
    TWTRTweet *tweet = archivedTweet.trTweet;
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}


- (void) makeRounds:(UIView*)v radius:(float)r
{
    if (v==nil) return;
    v.layer.masksToBounds = YES;
    v.layer.cornerRadius = r;
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
