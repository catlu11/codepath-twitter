//
//  DetailsViewController.m
//  twitter
//
//  Created by Catherine Lu on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "TweetCell.h"
#import "DateTools.h"
#import "APIManager.h"
#import "TimelineViewController.h"
#import "ReplyViewController.h"
#import "ProfileViewController.h"

@interface DetailsViewController () <ReplyViewControllerDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet WKWebView *mediaWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaWebViewHeight;
@property (weak, nonatomic) IBOutlet ReplyButton *replyButton;
@property (weak, nonatomic) IBOutlet ProfileButton *profileButton;
@property (weak, nonatomic) IBOutlet UITableView *replyTableView;
@property (strong, nonatomic) NSMutableArray *arrayOfReplies;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set UI elements
    [self refreshData];
    
    self.arrayOfReplies = [[NSMutableArray alloc] init];
    
    // Set user profile image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [self.profileButton setBackgroundImage:[UIImage imageWithData:urlData] forState:UIControlStateNormal];
    self.profileButton.layer.cornerRadius = self.profileButton.frame.size.width / 3;
    self.profileButton.clipsToBounds = YES;
    
    // Enable reply button
    self.replyButton.originalTweet = self.tweet;
    [self.replyButton addTarget:self action:@selector(beginReply:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set up replies table
    self.replyTableView.dataSource = self;
    [self fetchReplies];
    
}

-(void) fetchReplies {
//    NSLog(self.tweet.idStr);
    [[APIManager shared] getRepliesToTweetWithCompletion:self.tweet completion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded reply tweets");
            for(Tweet *tweet in tweets) {
                [self.arrayOfReplies addObject:tweet];
            }
            [self.replyTableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting reply tweets: %@", error.localizedDescription);
        }
    }];
}
- (IBAction)didTapProfile:(id)sender {
    ProfileViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewController.user = self.tweet.user;
    [viewController makeBackVisible];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction) beginReply:(id)sender {
    ReplyButton *buttonClicked = (ReplyButton *)sender;
    ReplyViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
    viewController.tweet = buttonClicked.originalTweet;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReply:(Tweet *)tweet {
    self.tweet.replyCount += 1;
    self.tweet.replied = YES;
    [self.arrayOfReplies insertObject:tweet atIndex:0];
    [self refreshData];
    [self.replyTableView reloadData];
}

- (void)refreshData {
    // Set screen name and username
    self.userTagLabel.text = [@"@" stringByAppendingString:self.tweet.user.screenName];;
    self.screenNameLabel.text = self.tweet.user.name;
    
    // Set date label
    if ([self.tweet.date isEarlierThan:[[NSDate date] dateBySubtractingMonths:1]]) {
        self.dateLabel.text = self.tweet.createdAtString;
    }
    else {
        self.dateLabel.text = self.tweet.date.shortTimeAgoSinceNow;
    }
    
    // Set tweet content label
    self.tweetTextView.text = self.tweet.text;
    
    // Set counts labels
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.likeLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", self.tweet.replyCount];
    
    // Update retweet button icon
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon-green"] forState:UIControlStateNormal];
    }
    else {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // Update favorite button icon
    if (self.tweet.favorited) {
        [self.likeButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
    }
    else {
        [self.likeButton setImage:[UIImage imageNamed: @"favor-icon"] forState:UIControlStateNormal];
    }
    
    self.mediaWebView.scrollView.scrollEnabled = NO;
    if(self.tweet.imageUrlArray.count > 0) {
        NSString *urlString = [self.tweet.imageUrlArray objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        self.mediaImageView.image = [UIImage imageWithData:urlData];
        
        double width = self.mediaImageView.frame.size.width;
        double ratio = width / self.mediaImageView.image.size.width;
        int frameHeight = (int) round(self.view.frame.size.height * 0.35);
        int modifiedImgHeight = (int) round(self.mediaImageView.image.size.height * ratio);
        int minHeight = MIN(frameHeight, modifiedImgHeight);

        if(minHeight > 0) {
            self.mediaImageHeightConstraint.constant = minHeight;
        }
        else {
            self.mediaImageHeightConstraint.constant = frameHeight;
        }
        self.mediaWebViewHeight.constant = 0;
    }
    else if(self.tweet.videoUrlArray.count > 0) {
        self.mediaWebViewHeight.constant = 200;
        self.mediaImageHeightConstraint.constant = 0;
        NSString *urlString = [self.tweet.videoUrlArray objectAtIndex:0];
        NSURLRequest *mediaRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:10.0];
        [self.mediaWebView loadRequest:mediaRequest];
    }
    else {
        self.mediaImageHeightConstraint.constant = 0;
        self.mediaWebViewHeight.constant = 0;
    }
}
- (IBAction)didTapRetweet:(id)sender {
    // retweet
    if (self.tweet.retweeted) {
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
                 self.tweet.retweeted = NO;
                 self.tweet.retweetCount -= 1;
                 [self refreshData];
             }
         }];
    }
    // unretweet
    else {
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
                 self.tweet.retweeted = YES;
                 self.tweet.retweetCount += 1;
                 [self refreshData];
             }
         }];
    }
}
- (IBAction)didTapLike:(id)sender {
    // favorite
    if (self.tweet.favorited) {
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
                 self.tweet.favorited = NO;
                 self.tweet.favoriteCount -= 1;
                 [self refreshData];
             }
         }];
    }
    // unfavorite
    else {
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
                 self.tweet.favorited = YES;
                 self.tweet.favoriteCount += 1;
                 [self refreshData];
             }
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *navigationController = self.navigationController;
    DetailsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    TweetCell *cell = [self tableView:self.replyTableView cellForRowAtIndexPath:indexPath]; // obtain from table cell to transfer local UI updates
    viewController.tweet = cell.tweet;
    [viewController refreshData];
    [navigationController pushViewController: viewController animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    // Get tweet and update cell UI
    Tweet *tweet = self.arrayOfReplies[indexPath.row];
    cell.tweet = tweet;
    [cell refreshData];
    
    // Enable reply button
    cell.replyButton.originalTweet = tweet;
    [cell.replyButton addTarget:self action:@selector(beginReply:) forControlEvents:UIControlEventTouchUpInside];
    
    // Enable profile clicking
    cell.profileButton.user = tweet.user;
    [cell.profileButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    // Remove selection style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%i", self.arrayOfReplies.count);
    return self.arrayOfReplies.count; // home timeline should show up to 20 tweets
}

@end
