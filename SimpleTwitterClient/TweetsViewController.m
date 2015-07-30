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
#import "TableViewDismissing.h"
#import "TweetDetailsViewController.h"


static NSString * const TweetTableReuseIdentifier = @"TweetCell";
static NSInteger const kTweetInputMinHeight = 110;
static NSInteger const kTweetInputMaxHeight = 170;


typedef NS_ENUM(NSInteger, TweetInputMode) {
    TweetInputModeCompact,
    TweetInputModeFull
};


@interface TweetsViewController () <TWTRTweetViewDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, TableViewDismissingDelegate>

@property (weak, nonatomic) IBOutlet TableViewDismissing *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createTweetButton;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *tweetSymolsCountLabel;



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
    [self makeRounds:self.tweetTextView radius:5];
    self.tweetTextView.layer.borderWidth = 1;
    self.tweetTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self makeRounds:self.createTweetButton radius:5];
    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    //self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    self.tableView.dismissingDelegate = self;
    
    self.tweetSymolsCountLabel.alpha = 0.0f;
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


# pragma mark - TableViewDismissingDelegate Methods


- (void) tableViewTapped {
    [self.tweetTextView resignFirstResponder];
}


# pragma mark - Compose tweet Methods


- (IBAction)newTweetTapped:(UIButton *)sender {
    if (self.tweetTextView.text.length <= 0) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[TweetsStore sharedStore] postTweetWithText:self.tweetTextView.text completionBlock:^(NSError *error) {
        if (error == nil) {
            [weakSelf.tweetTextView resignFirstResponder];
            weakSelf.tweetTextView.text = @"";
            [Utils showHUDWithText:@"Tweet posted." inView:weakSelf.view];
            [weakSelf refreshTable];
        } else {
            [Utils showHUDWithText:@"Can't post tweet." inView:weakSelf.view];
        }
    }];
}


- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTweetInputView];
}


- (void) updateTweetInputView {
    NSInteger left = 160 - self.tweetTextView.text.length;
    self.tweetSymolsCountLabel.text = [NSString stringWithFormat:@"%d", left];
    if (left < 0) {
        self.createTweetButton.alpha = 0.6f;
        self.createTweetButton.enabled = NO;
        self.tweetSymolsCountLabel.textColor = [UIColor redColor];
    } else {
        self.createTweetButton.alpha = 1.0f;
        self.createTweetButton.enabled = YES;
        self.tweetSymolsCountLabel.textColor = [UIColor lightGrayColor];
    }
}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateTweetInputView];
    [self setTweetInputMode:TweetInputModeFull];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self setTweetInputMode:TweetInputModeCompact];
}


- (void) setTweetInputMode:(TweetInputMode)mode {
    __weak typeof(self) weakSelf = self;
    NSInteger height = (mode == TweetInputModeCompact ? kTweetInputMinHeight : kTweetInputMaxHeight);
    float countAlpha = (mode == TweetInputModeCompact ? 0.0f : 1.0f);
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.tweetSymolsCountLabel.alpha = countAlpha;
        weakSelf.tableView.tableHeaderView.frame = CGRectMake(0, 0, weakSelf.tableView.frame.size.width, height);
        weakSelf.tableView.tableHeaderView = weakSelf.tableView.tableHeaderView;
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
}


# pragma mark - Settings Methods


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
    cell.tweetView.userInteractionEnabled = NO;
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArchivedTweet* archivedTweet = self.tweets[indexPath.row];
    TWTRTweet *tweet = archivedTweet.trTweet;
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArchivedTweet* archivedTweet = self.tweets[indexPath.row];
    TWTRTweet *tweet = archivedTweet.trTweet;
    [self performSegueWithIdentifier:@"ShowDetails" sender:tweet];
}


# pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((TweetDetailsViewController*)segue.destinationViewController).trTweet = sender;
    
    
}




# pragma mark - Helper Methods

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
