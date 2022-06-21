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

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
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
