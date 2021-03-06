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
#import "ProfileViewController.h"

#define MEDIA_PREVIEW_HEIGHT 200
#define MEDIA_TIMEOUT 10.0

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
    // Set user image
    NSString *URLString = self.tweet.user.profilePicture;
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [self.profileButton setBackgroundImage:[UIImage imageWithData:urlData] forState:UIControlStateNormal];
    self.profileButton.layer.cornerRadius = self.profileButton.frame.size.width / 3;
    self.profileButton.clipsToBounds = YES;
    
    // Set username and screen name labels
    self.userTagLabel.text = [@"@" stringByAppendingString:self.tweet.user.screenName];
    self.nameLabel.text = self.tweet.user.name;
    
    // Set date label
    if ([self.tweet.createdAtDate isEarlierThan:[[NSDate date] dateBySubtractingMonths:1]]) {
        self.dateLabel.text = self.tweet.createdAtString;
    }
    else {
        self.dateLabel.text = self.tweet.createdAtDate.shortTimeAgoSinceNow;
    }
    
    // Set tweet content label
    self.tweetViewText.text = self.tweet.text;
    
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
    
    // Set media web view
    self.mediaWebView.scrollView.scrollEnabled = NO;
    if(self.tweet.imageUrlArray.count > 0) {
        NSString *urlString = [self.tweet.imageUrlArray objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        self.mediaImageView.image = [UIImage imageWithData:urlData];
        
        double width = self.mediaImageView.frame.size.width;
        double ratio = width / self.mediaImageView.image.size.width;
        self.imageViewHeightConstraint.constant = round(self.mediaImageView.image.size.height * ratio);
        self.webViewHeightConstraint.constant = 0;
    }
    else if(self.tweet.videoUrlArray.count > 0) {
        NSString *urlString = [self.tweet.videoUrlArray objectAtIndex:0];
        NSURLRequest *mediaRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:MEDIA_TIMEOUT];
        [self.mediaWebView loadRequest:mediaRequest];
        self.webViewHeightConstraint.constant = MEDIA_PREVIEW_HEIGHT;
        self.imageViewHeightConstraint.constant = 0;
    }
    else {
        self.imageViewHeightConstraint.constant = 0;
        self.webViewHeightConstraint.constant = 0;
    }
}

- (IBAction)didTapRetweet:(id)sender {
    [[APIManager shared] retweet:self.tweet.retweeted tweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
         if(error){
              NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
             self.tweet.retweetCount += (self.tweet.retweeted ? -1 : 1);
             self.tweet.retweeted = !self.tweet.retweeted;
             [self refreshData];
         }
     }];
}

- (IBAction)didTapFavorite:(id)sender {
    [[APIManager shared] favorite:self.tweet.favorited tweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
         if(error){
              NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully favoriting the following Tweet: %@", tweet.text);
             self.tweet.favoriteCount += (self.tweet.favorited ? -1 : 1);
             self.tweet.favorited = !self.tweet.favorited;
             [self refreshData];
         }
     }];
}

@end
