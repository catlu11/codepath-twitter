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

@interface DetailsViewController () <ReplyViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet WKWebView *mediaWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaWebViewHeight;
@property (weak, nonatomic) IBOutlet ReplyButton *replyButton;
@property (strong, nonatomic) IBOutlet UIView *view;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set UI elements
    [self refreshData];
    
    // Set user profile image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    self.profileImageView.image = [UIImage imageWithData:urlData];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 3;
    
    // Enable reply button
    self.replyButton.originalTweet = self.tweet;
    [self.replyButton addTarget:self action:@selector(beginReply:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction) beginReply:(id)sender {
    ReplyButton *buttonClicked = (ReplyButton *)sender;
    ReplyViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReplyViewController"];
    viewController.tweet = buttonClicked.originalTweet;
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReply:(NSString *)idStr {
    self.tweet.replyCount += 1;
    self.tweet.replied = YES;
    [self refreshData];
}

- (void)refreshData {
    // Set screen name and username
    self.userTagLabel.text = self.tweet.user.screenName;
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

@end
