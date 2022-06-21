//
//  TweetCell.m
//  twitter
//
//  Created by Catherine Lu on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"
#import "DateTools.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tweetViewText.textContainer.lineFragmentPadding = 0;
    self.tweetViewText.textContainerInset = UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshData {
    // Set username and screen name labels
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
    self.tweetViewText
        .text = self.tweet.text;
    
    // Set counts labels
    self.retweetLabel.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.likesLabel.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.replyLabel.text = [NSString stringWithFormat:@"%d", self.tweet.replyCount];
    
    // Update retweet icon
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon-green"] forState:UIControlStateNormal];
    }
    else {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // Update favorite icon
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

- (IBAction)didTapFavorite:(id)sender {
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
